# Extend FastSurfer's CUDA image
FROM deepmi/fastsurfer:cuda-v2.4.2

# Switch to root to perform installations and copy files
USER root

# === Kinderseg Scripts & Data ===
# Copy kinderseg scripts and set execute permission
COPY scripts /fastsurfer/kinderseg/scripts
RUN chmod +x /fastsurfer/kinderseg/scripts/run_kinderseg.sh

# Copy the GrowthCharts' data and license file
COPY Percetilcurves_LR_mov.rds /fastsurfer/kinderseg/
COPY license.txt /fastsurfer/kinderseg/.license

# Include asegstats2table and mri_segstats in FreeSurfer:
RUN chmod +x /fastsurfer/kinderseg/scripts/install_asegstats_segstats.sh && \
    /fastsurfer/kinderseg/scripts/install_asegstats_segstats.sh

# === Python Environment Extension ===
# Upgrade pip and install additional Python packages required for KinderSeg
RUN /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install fslpy nibabel numpy

# === Install Miniconda and Create Conda Environment ===
# Install dependencies required for Miniconda installation
RUN apt-get update && apt-get install -y wget bzip2 && rm -rf /var/lib/apt/lists/*

# Download and install Miniconda into /opt/miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
    bash /miniconda.sh -b -p /opt/miniconda && \
    rm /miniconda.sh

# Add conda to the PATH
ENV PATH="/opt/miniconda/bin:${PATH}"

# Set working directory for environment creation 
WORKDIR /fastsurfer/kinderseg

# Copy the R environment file 
COPY R_environment.yml .

# Create the Conda environment from the YAML file
RUN conda env create -f R_environment.yml


# === Switch Back to FastSurfer's Default User ===
USER nonroot

# === Keep FastSurfer's Original Workdir and Entrypoint ===
WORKDIR "/fastsurfer"

ENTRYPOINT ["/fastsurfer/Docker/entrypoint.sh", "/kinderseg/scripts/run_kinderseg.sh"]

CMD ["--help"]
