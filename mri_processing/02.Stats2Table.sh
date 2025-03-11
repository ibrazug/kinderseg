#!/bin/bash

export FREESURFER_HOME='/usr/local/freesurfer/7.4.1'
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Freesurfer v7 stats

export SUBJECTS_DIR="/media/raid/ibrazug/Dokumente/KindersegV2/Ibra/derivatives/Freesurfer7"

subs=($(ls -1d $SUBJECTS_DIR/sub*))

cd $SUBJECTS_DIR

#echo ${subs[@]}

stats_dir="$HOME/data/KinderSegV2/review_GitHub/stats"

segfiles=('aseg.stats' \ 
          'wmparc.stats' \
           'hipposubfields.lh.T1.v22.stats' \
           'hipposubfields.rh.T1.v22.stats' \
           'amygdalar-nuclei.lh.T1.v22.stats' \
           'amygdalar-nuclei.rh.T1.v22.stats')


asegstats2table --common-segs \
                --meas volume \
                --tablefile ${stats_dir}/FS7_aseg_all.csv \
                --statsfile aseg.stats\
                --subjects ${subs[@]} \
                --skip

asegstats2table --common-segs \
                --meas volume \
                --tablefile ${stats_dir}/FS7_hipposubfields.lh.T1.v22.csv \
                --statsfile hipposubfields.lh.T1.v22.stats\
                --subjects ${subs[@]} \
                --skip

asegstats2table --common-segs \
                --meas volume \
                --tablefile ${stats_dir}/FS7_hipposubfields.rh.T1.v22.csv \
                --statsfile hipposubfields.rh.T1.v22.stats\
                --subjects ${subs[@]} \
                --skip


aparcstats2table --hemi lh \
                    --meas volume \
                    --tablefile ${stats_dir}/FS7_lh.aparc_all.csv \
                    --subjects ${subs[@]} \
                    --skip \
                    --delimiter comma \
                    --parc 'aparc'

aparcstats2table --hemi rh \
                    --meas volume \
                    --tablefile ${stats_dir}/FS7_rh.aparc_all.csv \
                    --subjects ${subs[@]} \
                    --skip \
                    --delimiter comma \
                    --parc 'aparc'


