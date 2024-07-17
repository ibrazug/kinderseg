#!/bin/bash

# Set the SUBJECTS_DIR to the current working directory
export SUBJECTS_DIR="$PWD"

# Get the first subject directory
first_sub=$(ls -1d sub* | head -n 1)

# Generate volume stats table for the first subject only
asegstats2table --subjects "$first_sub" \
                --skip --all-segs \
                --tablefile "$SUBJECTS_DIR/volume.stats.${first_sub}.csv" \
                --statsfile="aparc.DKTatlas+aseg.deep.volume.stats" \
                --common-segs --meas volume

# Initialize eTIV stats file with header
echo "IDs,eTIV" > "$SUBJECTS_DIR/eTIV.stats.${first_sub}.csv"

# Extract eTIV for the first subject
etiv=$(mri_segstats --etiv-only --subject "$first_sub" | grep eTIV | awk "{print $4}")
echo "$first_sub,$etiv" >> "$SUBJECTS_DIR/eTIV.stats.${first_sub}.csv"
echo "eTIV written to $SUBJECTS_DIR/eTIV.stats.${first_sub}.csv for subject $first_sub"
