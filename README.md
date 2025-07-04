# KinderSeg: FastSurfer Database for Age-Specific Brain Volumes in Healthy Children


[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[![Repository DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.12773962-blue.svg)](https://doi.org/10.5281/zenodo.12773962)



### Code for the paper:
```
 Ibrahim Zughayyar, Martin Bauer, Christopher Güttler, Ana Luísa Marcelino, Fabienne Kühne, Claudia Buss, Christine Heim, Annette Aigner, 
 Anna Tietze, and Andrea Dell'Orco 
(2024, September 9).
A FastSurfer Database for Age-Specific Brain Volumes in Healthy Children:
A Tool for Quantifying Localized and Global Brain Volume Alterations in Pediatric Patients.

https://doi.org/10.31219/osf.io/dw7p4

https://osf.io/kj7hy/
```
[![Preprint DOI](https://img.shields.io/badge/DOI-10.31219/osf.io/dw7p4-blue.svg)](https://doi.org/10.31219/osf.io/dw7p4)

![Example Output](imgs/Fig5.png)

## Run with Docker 

```
git clone https://github.com/ibrazug/kinderseg.git
cd kinderseg/Docker
cp </path/to/your/license.txt> .
docker build -t kinderseg .
docker run --gpus all --rm \
    -v <nifti_data>:/data \
    -v <output_dir>:/output \
    kinderseg \
    --age <age> \
    --threads <threads, optional, default=4>
```
 IMPORTANT NOTE: --threads is used to define the number of threads in total. not per hemisphere. 


`nifti_data` can be either a directory containing NIfTI files or a single NIfTI file. The output will be saved in the `output` directory in a subdirectory named after the input NIfTI file, without the extension. Example:

```
docker run --gpus all --rm \
    -v $PWD/sub-001/ses-01/anat/sub-001_ses-01_T1w.nii.gz:/data/sub-001_ses-01_T1w.nii.gz \
    -v ./output:/output \
    kinderseg --age 12
```

## Run with Apptainer/Singularity

```bash
git clone https://github.com/ibrazug/kinderseg.git
cd kinderseg/Docker
cp </path/to/your/freesurfer/license.txt> .  # copy your FreeSurfer license into this folder
docker build -t kinderseg .
apptainer build kinderseg.sif docker-daemon://kinderseg:latest

# Run the container with proper mounting:
apptainer run --nv kinderseg.sif \
    -B <nifti_data>:/data \
    -B ./output:/output \
    --age 18 \
    --threads 14
````

**Notes:**

* Use relative paths (`./data`, `./output`) instead of `$PWD` to avoid mount errors.
* Bind all `-B` options **before** the image name (`kinderseg.sif`).


#### Requirements

- At least 5 GB of RAM
- GPU (optional, but recommended)
- a valid FreeSurfer license: you can get one for free by clicking [here](https://surfer.nmr.mgh.harvard.edu/registration.html).
- we also provided Docker.amd version for AMD chips. 



## Dataset Statistics

| Dataset      | N° in total | Ex (QC) | N° after QC | Ex (SC) | N° after SC |
|--------------|-------------|---------|-------------|---------|-------------|
| HBN          | 170         | 21      | 149         | 10      | 139         |
| LOC          | 125         | 32      | 93          | 1       | 92          |
| Kids2Health  | 211         | 5       | 206         | 1       | 205         |
| **Total**    | **506**     | **58**  | **448**     | **12**  | **436**     |


## MRI Segmentation and Volumetric Analysis of the dataset subjects

### MRI Post-processing
- DICOM data converted to NIfTI format using `dcm2niix` and  Python version 3.9 was used for data manipulation

### Segmentation Tools

1. **FreeSurfer v7.4:** Ran on a Slurm cluster with a 16-core Intel Xeon E5-2650 CPU, Utilized GNU Parallel for parallel processing

2. **FastSurfer v2.3.3:** Utilized FastSurferCNN pipeline on a workstation with an AMD 3970X CPU and NVIDIA GeForce RTX 3090 GPU


### Data Analysis


- R version 4.1.2  used for analysis
- Libraries: ggplot2, tidyverse, viridis (R)



## KinderSeg Module Files

The `kinderseg` directory contains the following key files and scripts:

1. **`metrics.py`**:  
   - Implements metrics and evaluation methods for comparing segmented brain volumes.  
   - Includes the `DiceNiiRois` class for calculating the Dice similarity coefficient between ROIs in NIfTI files.  
   - Outputs a Pandas DataFrame with the Dice similarity between all ROIs.  

2. **`sums.py`**:  
   - Contains utility classes for summarizing region of interest (ROI) data and volume tables.  
   - Classes:  
     - `SumNiiRois`: Summarizes ROIs as defined in the `sumroi_mapping.csv` file and generates output NIfTI files.  
     - `SumVolTable`: Summarizes volume tables (from FastSurfer and FreeSurfer) based on mapped ROIs, creating CSV output.  
   - Uses parallel processing to speed up calculations and ROI summarization.  

3. **`sumroi_mapping.csv`**:  
   - A CSV file that contains mappings between raw ROIs and summarized ROIs.  
   - Supports mappings from VINN and FreeSurfer 7 (FS7) formats.  
   - Used by `sums.py` to transform and summarize volume data efficiently.  





