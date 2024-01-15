[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository contains information about the subjects and MRI data used in our study, focusing on three distinct groups of healthy individuals aged between 4 and 18 years. The segmentation is based exclusively on T1-MPRAGE images.

### Dataset Statistics

| Dataset        | N° in total | Ex (QC) | N° after QC | Ex(sc) | N° after SC |
| -------------- | ----------- | ------- | ----------- | ------ | ----------- |
| HBN            | 170         | 24      | 146         | 3      | 143         |
| LOC            | 125         | 19      | 107         | 7      | 99          |
| Kids2Health    | 434         | 27      | 407         | 5      | 402         |
| Total          | 729         | 70      | 659         | 15     | 644         |

## MRI Post-processing
- DICOM data converted to NIfTI format using `dcm2niix` and  Python version 3.9 was used for data manipulation

### Segmentation Tools

1. **FreeSurfer v6.0:**
   - Ran on a Slurm cluster with a 16-core Intel Xeon E5-2650 CPU
   - Utilized GNU Parallel for parallel processing

2. **FastSurfer (Version 1):**
   - Employed for accelerated brain segmentation
   - Utilized FastSurferCNN pipeline on a workstation with an AMD 3970X CPU and NVIDIA GeForce RTX 3090 GPU

### Files:
- `01.generate_segmentation_outputs (freesurfer and fastsurfer).ipynb`  The provided code outlines a comprehensive pipeline for processing MRI data using both Freesurfer and Fastsurfer for segmentation and volume calculation. For Freesurfer, the pipeline involves preprocessing NIfTI-formatted MRI data, performing parallelized recon-all processing, calculating volumes for specified brain regions, and generating a table summarizing volume statistics for all subjects. The Fastsurfer pipeline includes installing the required environment, processing MRI data using Fastsurfer's run_fastsurfer.sh script, and creating a volume statistics table for all subjects. In the end, two tables, "freesurfer_aseg.volume.stats.csv" and "fastsurfer_aseg.volume.stats.csv," capture the volumetric information for both processing approaches. The code emphasizes adherence to the Brain Image Data Structure (BIDS) and streamlines the segmentation and volume analysis of neuroimaging data.
- `02.SumROIs (masks and volumes).ipynb`  Python code for generating masks and calculating volumes from segmentation outputs. The code begins by defining anatomical regions and labels, parsing the FreeSurfer color lookup table, and creating mappings between label numbers and names. It then proceeds to generate new masks for specified subjects based on segmentation data, handling cases where segmentation files are missing. The notebook also includes instructions for calculating volumes for predefined regions of interest (ROIs) using data from volume statistics files. The code cleans up the original volume table, defines and sums volumes for 16 predefined ROIs, and calculates relative volumes. The final results, including the generated masks and volume tables, are saved in CSV files.


## Data Analysis

- R version 4.1.2  used for analysis
- Libraries: ggplot2, tidyverse, viridis (R)

### Comparison Metrics `DICE_VOLLDIFF_AI_PLOTs.ipynb`
- Comparison of FastSurferCNN and FreeSurfer v6 using:
  - Dice similarity coefficient (DSC)
  #- Overlay ratio (OR)
  - Intraclass Correlation Coefficient (ICC)
  - Visualization of Asymmetry Index (AI) for 14 anatomical regions

### Age-specific Percentile Curves `Percentiles.ipynb`
- Established using FastSurfer for the entire database
- Separate visualizations for males and females


### Sanity Check of the Final Dataset `sanity_check_plot.ipynb`
- Comparative analysis to verify representativeness
- Comparison to findings in the study by [Bethlehem et al. (2022)](https://github.com/brainchart/Lifespan)



