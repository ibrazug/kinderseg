#!/bin/bash

# Move asegstats2table to the correct FreeSurfer directories
mv /fastsurfer/kinderseg/scripts/stats/asegstats2table/bin/asegstats2table /opt/freesurfer/bin/asegstats2table
mv /fastsurfer/kinderseg/scripts/stats/asegstats2table/python/scripts/asegstats2table /opt/freesurfer/python/scripts/asegstats2table
mv /fastsurfer/kinderseg/scripts/stats/asegstats2table/python/packages/freesurfer /opt/freesurfer/python/scripts/freesurfer

# Move mri_segstats to the correct FreeSurfer directory
mv /fastsurfer/kinderseg/scripts/stats/mri_segstats /opt/freesurfer/bin/mri_segstats


# Make both mri_segstats and asegstats2table executable
chmod +x /opt/freesurfer/bin/mri_segstats
chmod +x /opt/freesurfer/bin/asegstats2table
