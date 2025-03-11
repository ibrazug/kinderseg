#!/bin/bash

##SBATCH --job-name=KindersegGPU
#SBATCH --time=00:15:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --mem=16G
#SBATCH --tasks=12
#SBATCH --array=-454

sub_dir="$HOME/ag_work/dellorca/data/KinderSeg"
dest_dir="$sub_dir/derivatives/FastsurferVINN_CC"

mkdir -p $dest_dir

cd $sub_dir

sids=($(ls -d sub-*))
sid=${sids[$SLURM_ARRAY_TASK_ID]}

nii=`ls $sub_dir/${sid}/*_T1w.nii.gz`
nii_dir=`dirname $nii`
nii_file=`basename $nii`

echo $sid
echo $nii
echo $nii_dir
echo $nii_file

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
                 --threads 12 \
                 --parallel \
                 --seg_only \
		        --tal_reg