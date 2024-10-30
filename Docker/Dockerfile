# Start with ubuntu base
FROM ubuntu:20.04 

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install packages needed for build
RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      unzip \
      ca-certificates \
      upx \
      file \
      tcsh \
      time \
      bc \
      gawk \
      libgomp1 && \
    wget https://github.com/Deep-MI/FastSurfer/archive/refs/tags/v1.1.2.zip && \
    unzip v1.1.2.zip -d /opt && \
    rm v1.1.2.zip && \
    mv /opt/FastSurfer-1.1.2 /opt/FastSurfer && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set PATH
ENV PATH /opt/conda/bin:$PATH

WORKDIR /opt

# Copy the environment.yml and create the env
COPY environment.yml .
RUN conda env create -f environment.yml

# Install PyTorch and torchvision
RUN /opt/conda/bin/conda run -n kinderseg pip install torch==1.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
RUN /opt/conda/bin/conda run -n kinderseg pip install torchvision==0.11.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

# Copy R_environment.yml and create the R env
COPY R_environment.yml .
RUN conda env create -f R_environment.yml

# Install pruned FreeSurfer and point to new Python location    
RUN /opt/FastSurfer/Docker/install_fs_pruned.sh /opt --upx && \
    rm /opt/freesurfer/bin/fspython && \
    ln -s /opt/conda/envs/kinderseg/bin/python /opt/freesurfer/bin/fspython

# Copy the scripts
COPY /scripts /opt/scripts

# Include asegstats2table and mri_segstats in FreeSurfer
RUN chmod +x /opt/scripts/install_asegstats_segstats.sh
RUN /opt/scripts/install_asegstats_segstats.sh

# Copy the GrowthCharts' data
COPY Percetilcurves_LR_mov.rds .

# Set execute permissions
RUN chmod +x /opt/scripts/run_kinderseg.sh

# Require license.txt file to be present
COPY license.txt /opt/freesurfer/.license

ENTRYPOINT ["/bin/bash", "/opt/scripts/run_kinderseg.sh"]
