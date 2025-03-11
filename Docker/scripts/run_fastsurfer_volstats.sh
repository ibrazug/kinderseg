#!/bin/bash


# Create the destination directory if it doesn't exist
mkdir -p $dest_dir


# Define the subject ID and threads
sub="$1"
threads="$2"

echo "Processing subject: $sub with FastSurfer..."
# Check if the segmentation already exists
if [ ! -e "${dest_dir}/${sub}/stats/aseg+DKT.stats" ]; then 
    # Locate the T1 image for the subject
    t1=$(ls ${src_dir}/*.nii.gz 2>/dev/null | head -n 1)

    if [ -z "$t1" ]; then
        echo "No T1 image found for subject ($sub) in $src_dir."
        exit 1
    fi


    # Run FastSurfer segmentation
    /fastsurfer/run_fastsurfer.sh --threads "$threads" \
                        --sd $dest_dir \
                        --no_cereb \
                        --no_hypothal \
                        --sid $sub \
                        --t1 $t1 \
                        --seg_only \
                        --3T \
                        --allow_root \
                        --fs_license /fastsurfer/kinderseg/.license

##CHECK 3T ???? which flags


else
    echo "Segmentation for subject $sub found! Skipping the segmentaion."
fi

echo "========================================"


SUBJECTS_DIR="/output" 

# echo "Processing subject: Generating volume stats table for $sub"
# # Check if the segmentation already exists
# if [ ! -e "${dest_dir}/${sub}/stats/volume.stats.csv" ]; then 

#     # Initialize eTIV stats file with header
#     echo "IDs,eTIV" > "${dest_dir}/${sub}/stats/eTIV.stats.csv"

#     # Extract eTIV for the first subject
#     etiv=$(mri_segstats --etiv-only --subject "$sub" | grep eTIV | awk '{print $4}')
#     echo "$sub,$etiv" >> "${dest_dir}/${sub}/stats/eTIV.stats.csv"
#     echo "eTIV written to ${dest_dir}/${sub}/stats/eTIV.stats.csv for subject $sub"


#     # Generate volume stats table for the first subject only
#     asegstats2table --subjects "$sub" \
#                     --skip --all-segs \
#                     --tablefile "${dest_dir}/${sub}/stats/volume.stats.csv" \
#                     --statsfile="aparc.DKTatlas+aseg.deep.volume.stats" \
#                     --common-segs --meas volume


# else
#     echo "volume stats table for $sub found! Skipping the process."
# fi


echo "========================================"

