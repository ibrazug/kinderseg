#!/bin/bash
#

export FREESURFER_HOME=$HOME/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

subs_dir="$HOME/sub"
export SUBJECTS_DIR=$subs_dir

cd $subs_dir
subs=($( ls -1d sub-* ))

echo ${subs[@]}

N=4

for s in ${subs[@]}
do
    ((i=i%N)); ((i++==0)) && wait
    if [ ! -d ${s}.reconall ] ; then
    	cd ${s} && \
    	files=($( ls -1 -r *.nii.gz)) && \
    	cd .. && \
        mri_convert ./${s}/$files ./${s}/orig.mgz && \
        recon-all -subjid $s.reconall -i ${s}/orig.mgz -all -parallel -openmp 4 &
    else
	echo "$s.reconall found. Skipping subject"
    fi
done


