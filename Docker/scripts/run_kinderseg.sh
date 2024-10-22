#!/bin/bash

# Check if a subject ID is provided
if [ -z "$1" ]; then
    echo "Please provide subject id in this format : $0 <subject_id> <age>"
    exit 1
fi


# Validate that age is a number (integer or float)
if ! [[ "$2" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Age must be a number."
    exit 1
fi

# Check if the age is between 4 and 19 using bc for float comparison
if (( $(echo "$2 < 4" | bc -l) )) || (( $(echo "$2 > 19" | bc -l) )); then
    echo "Age must be between 4 and 19."
    exit 1
fi


# Define the subject ID
sub="$1"
age="$2"


export src_dir="/data"                    # Directory with subjects (this will be a volume)
export dest_dir="/output"                 # Destination directory (this will be a volume)

# Create destination directory if it doesn't exist
mkdir -p "${dest_dir}/${sub}"

# Set up log file
log_file="${dest_dir}/${sub}/kinderseg_log_$(date +%Y%m%d_%H%M%S).log"

# Redirect stdout and stderr to the log file
exec > >(tee -a "$log_file") 2>&1

# Record start time
start_time=$(date +%s)

# Cool start message
echo "
╔═══════════════════════════════════════════════╗
║                 K I N D E R S E G             ║
╚═══════════════════════════════════════════════╝
"
echo "Kinderseg initiated at $(date) for $sub, age: $age"
echo "========================================"

source activate kinderseg
FREESURFER_HOME="/opt/freesurfer"
source $FREESURFER_HOME/SetUpFreeSurfer.sh

bash "/opt/scripts/run_fastsurfer_volstats.sh" "$sub"



#  python environment + python scirpt
conda activate kinderseg
python "/opt/scripts/data_processing.py" "$sub"



echo "========================================"
# R environment + R script
conda activate R_kinderseg
Rscript "/opt/scripts/data_analysis.R" "$sub" "$age"



# Calculate and display duration
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))


echo "========================================"
echo "Kinderseg processing completed at $(date)"
echo "Total duration: $hours hours, $minutes minutes, $seconds seconds"
# Sleep for a moment to ensure all output is shown
sleep 1
