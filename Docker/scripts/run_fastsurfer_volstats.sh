#!/bin/bash


# FastSurfer directories
fastsurfer_dir="/opt/FastSurfer"

# Create the destination directory if it doesn't exist
mkdir -p $dest_dir


# Define the subject ID
sub="$1"
echo "Processing subject: $sub with FastSurfer..."
# Check if the segmentation already exists
if [ ! -e "${dest_dir}/${sub}/stats/aparc.DKTatlas+aseg.deep.volume.stats" ]; then 
    # Locate the T1 image for the subject
    t1=$(ls ${src_dir}/*.nii.gz 2>/dev/null | head -n 1)

    if [ -z "$t1" ]; then
        echo "No T1 image found for subject ($sub) in $src_dir."
        exit 1
    fi

    cd $fastsurfer_dir


    # Run FastSurfer segmentation
    ./run_fastsurfer.sh --seg_only \
                        --vol_segstats \
                        --parallel --threads 4 \
                        --sd $dest_dir \
                        --sid $sub \
                        --t1 $t1



else
    echo "Segmentation for subject $sub found! Skipping the segmentaion."
fi

echo "========================================"


SUBJECTS_DIR="/output" 

echo "Processing subject: Generating volume stats table for $sub"
# Check if the segmentation already exists
if [ ! -e "${dest_dir}/${sub}/stats/volume.stats.csv" ]; then 

    # Initialize eTIV stats file with header
    echo "IDs,eTIV" > "${dest_dir}/${sub}/stats/eTIV.stats.csv"

    # Extract eTIV for the first subject
    etiv=$(mri_segstats --etiv-only --subject "$sub" | grep eTIV | awk '{print $4}')
    echo "$sub,$etiv" >> "${dest_dir}/${sub}/stats/eTIV.stats.csv"
    echo "eTIV written to ${dest_dir}/${sub}/stats/eTIV.stats.csv for subject $sub"


    # Generate volume stats table for the first subject only
    asegstats2table --subjects "$sub" \
                    --skip --all-segs \
                    --tablefile "${dest_dir}/${sub}/stats/volume.stats.csv" \
                    --statsfile="aparc.DKTatlas+aseg.deep.volume.stats" \
                    --common-segs --meas volume


else
    echo "volume stats table for $sub found! Skipping the process."
fi


echo "========================================"

