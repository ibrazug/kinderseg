[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12773962.svg)](https://doi.org/10.5281/zenodo.12773962)

Code for the paper:
```
Zughayyar, I., Bauer, M., Güttler, C., Marcelino, A. L., Kühne, F., Buss, C., … Dell'Orco, A. (2024, September 9). A FastSurfer Database for Age-Specific Brain Volumes in Healthy Children: A Tool for Quantifying Localized and Global Brain Volume Alterations in Pediatric Patients. https://doi.org/10.31219/osf.io/dw7p4

https://osf.io/kj7hy/
```

### Dataset Statistics

| Dataset      | N° in total | Ex (QC) | N° after QC | Ex (SC) | N° after SC |
|--------------|-------------|---------|-------------|---------|-------------|
| HBN          | 170         | 25      | 145         | 3       | 142         |
| LOC          | 125         | 20      | 105         | 7       | 98          |
| Kids2Health  | 211         | 7       | 204         | 3       | 201         |
| **Total**    | **506**     | **52**  | **454**     | **13**  | **441**     |

## Run ShinyApp Locally

To run the ShinyApp locally, follow these steps:

1. **Ensure you have R Studio installed on your machine.** Recommended version: RStudio 2023.06.2 Build 561.
2. **Download this repository** by clicking [here](https://github.com/ibrazug/kinderseg/archive/refs/heads/main.zip).
3. **Navigate to the `shinyapp` folder** within the downloaded repository.
4. **Open `app.R` using R Studio.**
5. **Install the shiny package** by running `install.packages("shiny")` in the R console if you haven't already.
6. **Run the App** by clicking on the `Run App` button in R Studio.

This will start the ShinyApp locally on your machine.



## MRI Post-processing
- DICOM data converted to NIfTI format using `dcm2niix` and  Python version 3.9 was used for data manipulation

### Segmentation Tools

1. **FreeSurfer v6.0:**
   - Ran on a Slurm cluster with a 16-core Intel Xeon E5-2650 CPU
   - Utilized GNU Parallel for parallel processing

2. **FastSurfer (V1):**
   - Employed for accelerated brain segmentation
   - Utilized FastSurferCNN pipeline on a workstation with an AMD 3970X CPU and NVIDIA GeForce RTX 3090 GPU

### Files:
- `01.generate_segmentation_outputs (freesurfer and fastsurfer).ipynb`  for MRI data segmentation and volume calculation using Freesurfer and Fastsurfer, generating volumetric statistics tables for both methods
- `02.SumROIs (masks and volumes).ipynb` defining and summing volumes for predefined ROIs, and saving the results in CSV files
- `Python_environment.yml` Python env


## Data Analysis

- R version 4.1.2  used for analysis
- Libraries: ggplot2, tidyverse, viridis (R)

### Files:
- `DSC_RVD.ipynb` showing how we calculated DSC and RVD values and how the figures were generated  
- `HAI.ipynb`  showing how HAI values were calculated for FastSurfer and FreeSurfer outputs
- `sanity_check_plot` Comparison to findings in the study by [Bethlehem et al. (2022)](https://github.com/brainchart/Lifespan)
- `ICC_and_mean_volumes` ICC Agreement Calculation and mean Volumes for each ROI.
- `Percetilcurves_LR` Established using FastSurfer for the entire database
- `R_environment` R env








