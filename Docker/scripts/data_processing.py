import sys
import os
import nibabel as nib
import numpy as np
from fsl.wrappers import fslreorient2std
import logging
import re

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Get the argument passed from the bash script
sub = sys.argv[1]  # The first argument (subject directory)

# Get the exported environment variables
dest_dir = os.environ.get('dest_dir')
src_dir = os.environ.get('src_dir')
freesurfer_dir = os.environ.get('FREESURFER_HOME')


# Define Regions of Interest (ROIs)
sumroi = {
    'Frontal': ['ctx.lh.caudalmiddlefrontal', 'ctx.rh.caudalmiddlefrontal', 'ctx.lh.lateralorbitofrontal',
                'ctx.rh.lateralorbitofrontal', 'ctx.lh.medialorbitofrontal', 'ctx.rh.medialorbitofrontal',
                'ctx.lh.parsopercularis', 'ctx.rh.parsopercularis', 'ctx.lh.parsorbitalis', 'ctx.rh.parsorbitalis',
                'ctx.lh.parstriangularis', 'ctx.rh.parstriangularis', 'ctx.lh.precentral', 'ctx.rh.precentral',
                'ctx.lh.rostralmiddlefrontal', 'ctx.rh.rostralmiddlefrontal', 'ctx.lh.superiorfrontal',
                'ctx.rh.superiorfrontal'],
    'Hippocampus': ['Left.Hippocampus', 'Right.Hippocampus'],
    'Frontal_Parietal': ['ctx.lh.paracentral', 'ctx.rh.paracentral'],
    'Parietal': ['ctx.lh.inferiorparietal', 'ctx.rh.inferiorparietal', 'ctx.lh.postcentral', 'ctx.rh.postcentral',
                 'ctx.lh.precuneus', 'ctx.rh.precuneus', 'ctx.lh.superiorparietal', 'ctx.rh.superiorparietal',
                 'ctx.lh.supramarginal', 'ctx.rh.supramarginal'],
    'Insula': ['ctx.lh.insula', 'ctx.rh.insula'],
    'Cingulate': ['ctx.lh.caudalanteriorcingulate', 'ctx.rh.caudalanteriorcingulate', 'ctx.lh.isthmuscingulate',
                  'ctx.rh.isthmuscingulate', 'ctx.lh.posteriorcingulate', 'ctx.rh.posteriorcingulate',
                  'ctx.lh.rostralanteriorcingulate', 'ctx.rh.rostralanteriorcingulate'],
    'Occipital': ['ctx.lh.cuneus', 'ctx.rh.cuneus', 'ctx.lh.lateraloccipital', 'ctx.rh.lateraloccipital',
                  'ctx.lh.lingual', 'ctx.rh.lingual', 'ctx.lh.pericalcarine', 'ctx.rh.pericalcarine'],
    'BasalGanglia': ['Left.Caudate', 'Right.Caudate', 'Left.Putamen', 'Right.Putamen', 'Left.Pallidum',
                     'Right.Pallidum', 'Left.Accumbens.area', 'Right.Accumbens.area'],
    'Thalamus': ['Left.Thalamus', 'Right.Thalamus'],
    'Cerebellum': ['Left.Cerebellum.White.Matter', 'Right.Cerebellum.White.Matter', 'Left.Cerebellum.Cortex',
                   'Right.Cerebellum.Cortex'],
    'CorpusCallosum': ['CC_Posterior', 'CC_Mid_Posterior', 'CC_Central', 'CC_Mid_Anterior', 'CC_Anterior'],
    'Ventricles': ['Left.Lateral.Ventricle', 'Right.Lateral.Ventricle', 'Left.Inf.Lat.Vent',
                   'Right.Inf.Lat.Vent', 'Left.choroid.plexus', 'Right.choroid.plexus', '3rd.Ventricle',
                   '4th.Ventricle', 'CSF'],
    'VentralDC': ['Left.VentralDC', 'Right.VentralDC'],
    'WM': ['Left.Cerebral.White.Matter', 'Right.Cerebral.White.Matter'],
    'Brainstem': ['Brain.Stem'],
    'Temporal': ['Left-Amygdala', 'Right-Amygdala', 'ctx-lh-entorhinal', 'ctx-lh-fusiform', 'ctx-lh-inferiortemporal',
                 'ctx-lh-middletemporal', 'ctx-lh-parahippocampal', 'ctx-lh-superiortemporal',
                 'ctx-lh-transversetemporal', 'ctx-rh-entorhinal', 'ctx-rh-fusiform', 'ctx-rh-inferiortemporal',
                 'ctx-rh-middletemporal', 'ctx-rh-parahippocampal', 'ctx-rh-superiortemporal',
                 'ctx-rh-transversetemporal']
}


# Modify ROIs for mapping
for roi_category in sumroi:
    sumroi[roi_category] += [i.replace('.', '-') for i in sumroi[roi_category]]

# Create mapping dictionaries
our_map = {roi: idx + 1 for idx, roi in enumerate(sumroi.keys())}
our_map_inv = {v: k for k, v in our_map.items()}

# Load FreeSurfer LUT file and create label dictionaries
fs_labels_path = os.path.join(freesurfer_dir, 'FreeSurferColorLUT.txt')
d, d_inv = {}, {}

with open(fs_labels_path, 'r') as fin:
    for row in fin:
        src = re.search(r'([0-9]{1,4}) *([^ ]*) *[0-9]{1,3} *[0-9]{1,3} *[0-9]{1,3} *[0-9].*', row)
        if src and src[2]:
            d[int(src[1])] = src[2]
            d_inv[src[2]] = int(src[1])

# Map the sumroi to corresponding FreeSurfer numbers
sumroi_num = {roi: [d_inv[j.replace('.', '-')] for j in sumroi[roi]] for roi in sumroi}

# Function to convert MGZ to NIfTI
def convert_mgz_to_nii(sub_dir):
    t1w_mgz = nib.load(os.path.join(sub_dir, 'mri/T1.mgz'))
    t1w_nii = nib.Nifti1Image(t1w_mgz.get_fdata(), header=t1w_mgz.header, affine=t1w_mgz.affine)
    sid = os.path.basename(os.path.normpath(sub_dir))
    dest_fullpath = os.path.join(dest_dir, sid,'masks', 'T1.nii.gz')
    os.makedirs(os.path.dirname(dest_fullpath), exist_ok=True)
    nib.save(t1w_nii, dest_fullpath)
    logging.info(f"Converted T1.mgz to NIfTI: {dest_fullpath}")

# Function to create summary and individual masks
def create_masks(sub_dir):
    sid = os.path.basename(os.path.normpath(sub_dir))
    mask_mgz = nib.load(os.path.join(sub_dir, 'mri/aparc.DKTatlas+aseg.deep.withCC.mgz'))
    mask_arr = mask_mgz.get_fdata().copy()

    for roi in our_map.keys():
        values = sumroi_num[roi]
        for v in values:
            mask_arr = np.where(mask_arr == v, our_map[roi] * 1e4, mask_arr).astype(int)

    mask_arr = np.where(mask_arr < 1e4, 0, mask_arr) / 1e4
    mask_nii = nib.Nifti1Image(mask_arr, header=mask_mgz.header, affine=mask_mgz.affine)
    seg_mask_path = os.path.join(dest_dir, sid,'masks','seg_mask.nii.gz')
    os.makedirs(os.path.dirname(seg_mask_path), exist_ok=True)
    nib.save(mask_nii, seg_mask_path)
    logging.info(f"Created summary mask: {seg_mask_path}")

    # Create individual masks
    for v in np.unique(mask_arr).astype(int):
        if v != 0:
            roi_mask = np.where(mask_arr == v, mask_arr, 0)
            roi_nii = nib.Nifti1Image(roi_mask, header=mask_mgz.header, affine=mask_mgz.affine)
            roi_nii_path = os.path.join(dest_dir, sid,'masks', 'individual masks')
            roi_nii_name = os.path.join(roi_nii_path, f'seg_{our_map_inv[v]}.nii.gz')
            if not os.path.exists(roi_nii_path):
                os.makedirs(roi_nii_path)
            
            nib.save(roi_nii, roi_nii_name)
            logging.info(f"Created individual mask for ROI {our_map_inv[v]}: {roi_nii_name}")

# Main workflow
def process_subject(sub_dir):
    convert_mgz_to_nii(sub_dir)
    create_masks(sub_dir)

def create_freesurfer_color_lut(filename):
    content = """# No. Label Name                          R    G    B    A
 0   Unknown                               0    0    0    0
 1   Frontal                             70  130  180    0
 2   Hippocampus                        245  245  245    0
 3   Frontal_Parietal                  205   62   78    0
 4   Parietal                           120   18  134    0
 5   Insula                             196   58  250    0
 6   Cingulate                           0  148    0    0
 7   Occipital                         220  248  164    0
 8   BasalGanglia                      230  148   34    0
 9   Thalamus                            0  118   14    0
10   Cerebellum                          0  118   14    0
11   CorpusCallosum                     122  186  220    0
12   Ventricles                         236   13  176    0
13   VentralDC                          12   48  255    0
14   WM                                204  182  142    0
15   Brainstem                          42  204  164    0
16   Temporal                           119  159  176    0
"""

    with open(filename, 'w') as file:
        file.write(content)




# Run the script for one subject
masks_path = os.path.join(dest_dir,sub,'masks')
if os.path.exists(masks_path):
        logging.info(f"Skipping {sub}: 'masks' folder exists")
else:
    logging.info(f"creating 'masks' folder")
    process_subject(os.path.join(dest_dir,sub))
    create_freesurfer_color_lut(os.path.join(dest_dir,sub,'masks', 'modified_FreeSurferColorLUT_16ROI.txt'))
