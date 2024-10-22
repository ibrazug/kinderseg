## Start with ubuntu base
FROM ubuntu:20.04 

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive


# Install packages needed for build
RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      git \
      unzip \
      ca-certificates \
      upx \
      file \
      tcsh \
      time \
      bc \
      gawk \
      libgomp1 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Clone FastSurfer version 1.1.2 
RUN wget https://github.com/Deep-MI/FastSurfer/archive/refs/tags/v1.1.2.zip && \
    unzip v1.1.2.zip -d /opt && \
    rm v1.1.2.zip
# Move FastSurfer directory to a more convenient path
RUN mv /opt/FastSurfer-1.1.2 /opt/FastSurfer


# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Set PATH
ENV PATH /opt/conda/bin:$PATH


WORKDIR /opt

# Copy the environment.yml create the env
COPY environment.yml .
RUN conda env create -f environment.yml
RUN /bin/bash -c "source activate kinderseg && pip install torch==1.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html && \
pip install torchvision==0.11.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html"

# 
COPY R_environment.yml .
RUN conda env create -f R_environment.yml


# install pruned freesurfer and point to new python location    
RUN /opt/FastSurfer/Docker/install_fs_pruned.sh /opt --upx && \
    rm /opt/freesurfer/bin/fspython && \
    ln -s /opt/conda/envs/kinderseg/bin/python /opt/freesurfer/bin/fspython


COPY /scripts /opt/scripts

#include asegstats2table and mri_segstats in FreeSurfer
RUN chmod +x /opt/scripts/install_asegstats_segstats.sh
RUN /opt/scripts/install_asegstats_segstats.sh


#copy the GrowthCharts' data
COPY Percetilcurves_LR_mov.rds .


# Set execute permissions
RUN chmod +x /opt/scripts/run_kinderseg.sh


# Require license.txt file to be present
COPY license.txt /opt/freesurfer/.license


ENTRYPOINT ["/bin/bash","/opt/scripts/run_kinderseg.sh"]