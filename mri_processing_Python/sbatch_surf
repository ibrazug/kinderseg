#!/bin/bash

##SBATCH --job-name=KindersegCPU
#SBATCH --time=07:00:00
#SBATCH --partition=compute
#SBATCH --mem=32G
#SBATCH --tasks=10
#SBATCH --array=1-226

# To build the Singularity container: singularity build fastsurfer-gpu.sif docker://deepmi/fastsurfer:latest


sub_dir='/home/dellorca/ag_work/dellorca/data/KinderSeg'
dest_dir="$sub_dir/derivatives/FastsurferVINN"

mkdir -p $dest_dir

cd $sub_dir

sids=($(ls -d sub-*/))
sid=${sids[$SLURM_ARRAY_TASK_ID]}

nii=`ls $sub_dir/${sid}anat/*_T1w.nii.gz`
nii_dir=`dirname $nii`
nii_file=`basename $nii`
cd code

singularity exec --nv \
                 --no-home \
                 -B $nii_dir:/data\
                 -B $dest_dir:/output \
                 -B $sub_dir/code:/fs_license \
                 "$sub_dir/code/fastsurfer-gpu.sif" \
                 /fastsurfer/run_fastsurfer.sh \
                 --no_cereb \
                 --no_hypothal \
                 --t1 /data/$nii_file \
                 --sd /output/ \
                 --sid $sid \
                 --fs_license /fs_license/license.txt \
		         --3T \
                 --threads 10 \
                 --parallel \
                 --surf_only
