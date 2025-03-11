import pandas as pd
import os
import numpy as np
import nibabel as nib
from joblib import Parallel, delayed
from . import consts


class DiceNiiRois:
    """
    Kinderseg helper class to calculate Dice similarity coefficient between all the ROIs of a NIfTI
    It outputs a pandas DataFrame with the Dice similarity coefficient between all the ROIs.
    """
    def __init__(self, classes = None, 
                 class_names = None, 
                 n_jobs = 1):
        self.classes = classes
        self.class_names = class_names
        self.ids_list = ids_list
        self.n_jobs = n_jobs
    
    def calc_dice(nii1, nii2):
        
        if isinstance(nii1, str) and isinstance(nii2, str):
            results = self.__calc_single_dice(nii1, nii2)
        elif isinstance(nii1, list) and isinstance(nii2, list):
            # To be implemented: use multithread for both multiple dices and multiple images
            results = Parallel(n_jobs=1)(delayed(self.__calc_single_dice)(nii1[i], nii2[i]) for i in range(len(nii1)))
        if not self.class_names:
            self.class_names = [str(i) for i in self.classes]
        df = pd.DataFrame(results, columns=self.class_names)
        return df
                    
        
    
    def __calc_single_dice(self, nii1, nii2):
        
        if isinstance(nii1, str):
            nii1 = nib.load(nii1).get_fdata().astype(np.uint8)
        if isinstance(nii2, str):
            nii2 = nib.load(nii2).get_fdata().astype(np.uint8)
        if nii1.shape != nii2.shape:
            raise ValueError('Input images must have the same shape')
        if self.classes is None:
            self.classes = np.unique(nii1)
            if self.classes != np.unique(nii2):
                raise ValueError('Input images must have the same classes')
        def __calc_dice(class_id):
            mask1 = np.where(nii1 == class_id, 1, 0).astype(bool)
            mask2 = np.where(nii2 == class_id, 1, 0).astype(bool)
            return 2*np.logical_and(mask1, mask2).sum()/(mask1.sum() + mask2.sum())
        
        results = Parallel(n_jobs=self.n_jobs)(delayed(__calc_dice)(class_id) for class_id in self.classes)
        return results