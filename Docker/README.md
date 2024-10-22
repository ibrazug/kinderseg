[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12773962.svg)](https://doi.org/10.5281/zenodo.12773962)


# KinderSeg Docker

This repository contains a Dockerfile for creating an environment to run KinderSeg, a processing pipeline for analyzing brain imaging data using FastSurfer and custom scripts. The environment is built on Ubuntu 20.04 and includes Miniconda for managing Python and R environments.It uses FastSurfer version 1.1.2 and a pruned version of FreeSurfer (the installation of a pruned version described [here](https://github.com/Deep-MI/FastSurfer/blob/v1.1.2/Docker/install_fs_pruned.sh)), in additon to the `asegstats2table` and `mri_segstats` utilities.


## Requirements

- At least 5 GB of RAM
- `License.txt` file in the same directory as the Dockerfile
- GPU (optional, but recommended)

 **_NOTE:_**  Ensure you have a valid FreeSurfer license. The license file should be placed in Docker folder mext to Dockerfile. You can can the license from [here](https://surfer.nmr.mgh.harvard.edu/registration.html)


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
- stats: Contains statistical output files.
- masks: New folder for storing generated mask files.
- kinderseglogYYYYMMDD_HHMMSS.log: Log file containing processing details and duration.
- modified_FreeSurferColorLUT_16ROI.txt: This can be used to name the masks correctly while viewing with [Freeview](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeviewGuide/FreeviewGeneralUsage)

## Usage
To run the KinderSeg pipeline, use the following command:
bash

```
docker run --gpus all --rm -v /home/user/my_mri_data:/data-v C:/Users/Ibrah/Downloads/output:/output kinderseg <subject_id> <age>
```
**_IMPORTANT NOTE:_** my_mri_data: a folder with a *.nii.gz file
- --gpus all: Use all available GPUs.
- --rm: Automatically remove the container when it exits.
- -v: Mounts host directories for input and output.

Parameters
<subject_id>: The ID of the subject you are processing.
<age>: The age of the subject (must be between 4 and 19).




## TODO 
- check if fastsurfer swgmentation is done crrectly before running python and R scripts
- specfiy conda version in RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
- specfiy lapy version in environment.yml



## Examples on Windows 11
- if you run the script and and output volume is refrencing a fastsurfer output with volstat. The masks and the growth chart gets generated. It takes a few second to generate the output

```
docker run --gpus all --rm -v C:/Users/<user>/GitHub/sub-N060/anat:/data -v C:/Users/<user>/GitHub/output:/output kinderseg sub-N060 11.18
..
╔═══════════════════════════════════════════════╗
║                 K I N D E R S E G             ║
╚═══════════════════════════════════════════════╝

Kinderseg initiated at Tue Oct 22 08:35:31 UTC 2024 for sub-N060, age: 11.18
========================================
INFO: /root/matlab/startup.m does not exist ... creating
Processing subject: sub-N060 with FastSurfer...
Segmentation for subject sub-N060 found! Skipping the segmentaion.
========================================
Processing subject: Generating volume stats table for sub-N060
volume stats table for sub-N060 found! Skipping the process.
========================================
2024-10-22 08:35:32,707 - INFO - Skipping sub-N060: 'masks' folder exists
========================================
Warning message:
package ‘ggplot2’ was built under R version 4.3.3 

Attaching package: ‘dplyr’

The following objects are masked from ‘package:stats’:

    filter, lag

The following objects are masked from ‘package:base’:

    intersect, setdiff, setequal, union

Warning message:
package ‘dplyr’ was built under R version 4.3.3 
── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ lubridate 1.9.3     ✔ tibble    3.2.1
✔ purrr     1.0.2     ✔ tidyr     1.3.1
✔ readr     2.1.5     
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
Warning messages:
1: package ‘tidyverse’ was built under R version 4.3.3 
2: package ‘tibble’ was built under R version 4.3.3 
3: package ‘tidyr’ was built under R version 4.3.3 
4: package ‘readr’ was built under R version 4.3.3 
5: package ‘purrr’ was built under R version 4.3.3 
6: package ‘stringr’ was built under R version 4.3.3 
7: package ‘forcats’ was built under R version 4.3.3 
8: package ‘lubridate’ was built under R version 4.3.3 
NOTE: Either Arial Narrow or Roboto Condensed fonts are required to use these themes.
      Please use hrbrthemes::import_roboto_condensed() to install Roboto Condensed and
      if Arial Narrow is not on your system, please see https://bit.ly/arialnarrow

Attaching package: ‘zoo’

The following objects are masked from ‘package:base’:

    as.Date, as.Date.numeric

Warning message:
package ‘zoo’ was built under R version 4.3.3 
`geom_smooth()` using formula = 'y ~ x'
`geom_smooth()` using formula = 'y ~ x'
`geom_smooth()` using formula = 'y ~ x'
Warning messages:
1: Removed 64 rows containing non-finite outside the scale range
(`stat_smooth()`). 
2: Removed 64 rows containing non-finite outside the scale range
(`stat_smooth()`). 
3: Removed 64 rows containing non-finite outside the scale range
(`stat_smooth()`). 
========================================
Kinderseg processing completed at Tue Oct 22 08:35:37 UTC 2024
Total duration: 0 hours, 0 minutes, 6 seconds

```

