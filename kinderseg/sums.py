import pandas as pd
import os
import numpy as np
import nibabel as nib
from joblib import Parallel, delayed
from . import consts

class SumNiiRois:
    """
    Kinderseg helper class to summarize ROIs as mapped in sumroi_mapping.csv
    
    Example:
    >>> from kinderseg.sums import SumNiiRois
    >>> sumrois = SumNiiRois()
    >>> sumrois.transform('path/to/roi.nii.gz')
    >>> sumrois.to_filename('path/to/sumroi.nii.gz')    
    """
    
    
    def __init__(self, src='VINN', n_jobs=1):
        self.n_jobs = n_jobs
        self.src = src
        self.mapping = self._load_mapping()
        self.sum_data = None
        self.sum_nii = None
        self.src_nii = None
        self.src_data = None
        self.src_affine = None
        self.src_header = None
        
    def _load_mapping(self):
        module_dir = os.path.dirname(__file__)
        csv_path = os.path.join(module_dir, 'sumroi_mapping.csv')
        df = pd.read_csv(csv_path)
        if 'VINN' in self.src:
            df = df[['VINN_N', 'Sum_N']]
        elif '7' in self.src:
            df = df[['FS7_N', 'Sum_N']]
        return df
    
    
    def transform(self, src_nii):
        self.src_nii = nib.load(src_nii)
        self.src_data = self.src_nii.get_fdata()
        self.src_affine = self.src_nii.affine
        self.src_header = self.src_nii.header
        self.sum_data = np.zeros_like(self.src_data)
        # for roi_num in set(self.mapping['Sum_N'].values):
        #     orig_nums = self.mapping[self.mapping['Sum_N'] == roi_num]['VINN_N'].values
        #     self.sum_data += np.where(np.isin(self.src_data, orig_nums), roi_num*1e5, 0) # Multiply by 1e5 to avoid overlap
        def __process_roi(roi_num):
            orig_nums = self.mapping[self.mapping['Sum_N'] == roi_num][self.mapping.columns[0]].values
            return np.where(np.isin(self.src_data, orig_nums), roi_num*1e5, 0)

        
        results = Parallel(n_jobs=self.n_jobs)(delayed(__process_roi)(roi_num) for roi_num in set(self.mapping['Sum_N'].values))
        self.sum_data = (np.stack(results).sum(axis=0)/1e5).astype(np.uint16)
        del results

        self.sum_nii = nib.Nifti1Image(self.sum_data, self.src_affine, self.src_header)
        return self.sum_nii
    
    def to_filename(self, filename):
        nib.save(self.sum_nii, filename)
        return filename
    
    def __repr__(self):
        return self.sum_nii.__repr__()
    
    def __str__(self):
        return self.sum_nii.__str__()


class SumVolTable:
    """ 
    Kinderseg helper class to summarize volume tables from Fastsurfer and Freesurfer to the summarized ROIs
    
    Example:
    >>> from kinderseg.sums import SumVolTable
    >>> sumvol = SumVolTable()
    >>> sumvol.transform(fastsurfer_table)
    >>> sumvol.to_filename('path/to/sumroi_table.csv')
    """
    
    def __init__(self, src='VINN', n_jobs=1) -> None:
        self.src = src
        self.mapping = self._load_mapping()
        self.table = None
        self.index_dir = None
    
    def _load_mapping(self):
        module_dir = os.path.dirname(__file__)
        csv_path = os.path.join(module_dir, 'sumroi_mapping.csv')
        df = pd.read_csv(csv_path)
        if 'VINN' in self.src:
            self.src = 'VINN_ROI'
            df = df[[self.src, 'Sum_ROI']]
        elif '7' in self.src:
            self.src = 'FS7_ROI'
            df = df[[self.src, 'Sum_ROI']]
        return df
    
    def transform(self, src_table: pd.DataFrame, index_dir: str = 'sids', eTIV: bool = True) -> pd.DataFrame:
        """

        Args:
            src_table (_type_): path to the volume table from Fastsurfer or Freesurfer
            index_dir (str, optional): name of the index/IDs column in the table. Defaults to 'sids'.
            eTIV (bool, optional): add eTIV column. Defaults to True.

        Returns:
            _type_: _description_
        """
        self.index_dir = index_dir
        self.table = pd.DataFrame()
        self.table[self.index_dir] = src_table[self.index_dir]
        if eTIV:
            if 'eTIV' in src_table.columns:
                self.table['eTIV'] = src_table['eTIV']
            elif 'EstimatedTotalIntraCranialVol' in src_table.columns:
                self.table['eTIV'] = src_table['EstimatedTotalIntraCranialVol']
                
        rois_cat = set(self.mapping['Sum_ROI'].values)
        for roi in rois_cat:
            orig_rois = self.mapping[self.mapping['Sum_ROI'] == roi][self.src].values
            self.table[roi] = src_table[orig_rois].sum(axis=1)
        return self
    
    def to_filename(self, filename : str) -> str:
        self.table.to_csv(filename, index=False)
        return filename
    
    def __repr__(self):
        return self.table.__repr__()
    
    def __str__(self):
        return self.table.__str__()