[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12773962.svg)](https://doi.org/10.5281/zenodo.12773962)


# KinderSeg Docker

This repository contains a Dockerfile for creating an environment to run KinderSeg, a processing pipeline for analyzing brain imaging data using FastSurfer and custom scripts. The environment is built on Ubuntu 20.04 and includes Miniconda for managing Python and R environments. It uses FastSurfer version 1.1.2 and a pruned version of FreeSurfer (the installation of a pruned version described [here](https://github.com/Deep-MI/FastSurfer/blob/v1.1.2/Docker/install_fs_pruned.sh)), in addition to the `asegstats2table` and `mri_segstats` utilities.


## Requirements

- At least 5 GB of RAM
- `License.txt` file in the same directory as the Dockerfile
- GPU (optional, but recommended)

 **_NOTE:_**  Ensure you have a valid FreeSurfer license. The license file should be placed in Docker folder next to the Dockerfile. You can get the license from [here](https://surfer.nmr.mgh.harvard.edu/registration.html)


## Directory Structure

The output of the KinderSeg pipeline is organized as follows:

```
<subject_id>
├── stats/
│   ├── eTIV.stats.csv
│   └── volume.stats.csv
├── GrowthChart.jpg
├── masks/
│   ├── T1.nii.gz
│   ├── seg_mask.nii.gz
│   ├── modified_FreeSurferColorLUT_16ROI.txt
│   └── individual_masks/
│       ├── seg_BasalGanglia.nii.gz
│       ├── seg_Brainstem.nii.gz
│       ├── seg_Cerebellum.nii.gz
│       ├── seg_Cingulate.nii.gz
│       ├── seg_CorpusCallosum.nii.gz
│       ├── seg_Frontal.nii.gz
│       ├── seg_Frontal_Parietal.nii.gz
│       ├── seg_Hippocampus.nii.gz
│       ├── seg_Insula.nii.gz
│       ├── seg_Occipital.nii.gz
│       ├── seg_Parietal.nii.gz
│       ├── seg_Temporal.nii.gz
│       ├── seg_Thalamus.nii.gz
│       ├── seg_VentralDC.nii.gz
│       ├── seg_Ventricles.nii.gz
│       └── seg_WM.nii.gz
└── kinderseg_log_YYYYMMDD_HHMMSS.log
```

 **_IMPORTANT NOTE:_** in addition to the original files in the fastsurfer output

- <subject_id>: Folder for each subject processed.
- GrowthChart.jpg: Growth chart image for the subject.
- stats: Contains statistical output files. 16_Volumes.csv includes the absolute volume of each ROI.
- masks: New folder for storing generated mask files.
- kinderseglogYYYYMMDD_HHMMSS.log: Log file containing processing details and duration.
- modified_FreeSurferColorLUT_16ROI.txt: This can be used to name the masks correctly while viewing with [Freeview](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeviewGuide/FreeviewGeneralUsage)

## Usage
To run the KinderSeg pipeline, use the following command:
bash

```
docker run --gpus all --rm -v /home/user/my_mri_data:/data-v /home/user/output:/output kinderseg <subject_id> <age>

docker run --gpus all --rm \
    -v </home/user/my_mri_data>:/data \
    -v </home/user/output>:/output \
    kinderseg \
    --age <age> \
    --threads <threads>

example for running it without gput on 2 threads
docker run --rm \
  -v /home/user/documents/sub-xxx/anat:/data \
  -v /home/user/documents/output:/output \
  kinderseg \
  --age 10.5 \
  --threads 2


```
**_IMPORTANT NOTE:_** my_mri_data: a folder with a *.nii.gz file
- --gpus all (optional but highly recommended if a GPU is available): Use all available GPUs.
- --rm: Automatically remove the container when it exits.
- -v: Mounts host directories for input and output.
- - /home/user/my_mri_data:/data: Mounts the local directory containing the MRI data (*.nii.gz files) as /data in the container.
- - /home/user/documents/output:/output: Mounts the local output directory as /output in the container.

Parameters
<age>: The age of the subject (must be between 3 and 19).
<threads> (optional; default = 4): The ID of the subject you are processing.



## TODO 
- check if fastsurfer segmentation is done crrectly before running python and R scripts
- specfiy conda version in RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
- specfiy lapy version in environment.yml

