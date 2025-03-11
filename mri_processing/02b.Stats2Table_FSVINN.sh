#!/bin/bash

export FREESURFER_HOME='/usr/local/freesurfer/7.4.1'
source $FREESURFER_HOME/SetUpFreeSurfer.sh



segfiles=('aseg+DKT.stats')

export SUBJECTS_DIR="/media/raid/ibrazug/Dokumente/KindersegV2/Ibra/derivatives/FastSurferVINN"

subs=($(ls -1d $SUBJECTS_DIR/sub*))

cd $SUBJECTS_DIR

#echo ${subs[@]}

stats_dir="$HOME/data/KinderSegV2/review_GitHub/stats"

for stats in ${segfiles[@]}; do
    asegstats2table --common-segs \
                    --meas volume \
                    --tablefile ${stats_dir}/VINN_${stats}_all.csv \
                    --statsfile ${stats} \
                    --subjects ${subs[@]} \
                    --all-segs \
                    --skip
done

 