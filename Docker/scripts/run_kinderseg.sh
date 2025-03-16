#!/bin/bash


# Function to display help
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --age AGE        Age of the subject (required, between 3 and 19)"
    echo "  --threads THREAD Number of threads to use (default: 4)"
    echo "  --help           Show this help message"
    echo ""
    echo "This script processes neuroimaging data in .nii.gz format located in the /data directory."
    echo "It uses FreeSurfer, FastSurfer, and Python/R scripts for data processing and analysis."
    echo "The output will be stored in the /output directory with a log file."
    echo ""
}

# Check for --help flag and show help if present
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

#set -euo pipefail


# Default values
age=""
threads=4  # Default value for threads
sub=""

# Check if any .nii.gz file exists in the /data directory
if ls /data/*.nii.gz 1> /dev/null 2>&1; then
    # Get the first .nii.gz file in the directory without the extension
    sub=$(basename /data/*.nii.gz | head -n 1 | sed 's/\(.*\)\.nii\.gz/\1/')
else
    echo "Error: No .nii.gz files found in /data directory."
    exit 1
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --age)
            age="$2"
            shift 2
            ;;
        --threads)
            threads="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Check if age was provided and within range
if [ -z "$age" ]; then
    echo "Error: --age is required."
    exit 1
elif [ "$age" -lt 3 ] || [ "$age" -gt 19 ]; then
    echo "Error: Age should be between 3 and 19."
    exit 1
fi




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


echo "
╔═══════════════════════════════════════════════╗
║                 K I N D E R S E G             ║
╚═══════════════════════════════════════════════╝
"
echo "KindersegV0.3 initiated at $(date) for $sub, Age: $age, Threads: $threads"
echo "========================================"

# enabling Conda.

# Enable strict mode.
#set -euo pipefail
# ... Run whatever commands ...

# Temporarily disable strict mode and activate conda:
set +euo pipefail
#conda activate myenv
source /venv/bin/activate

# Re-enable strict mode:
set -euo pipefail

bash "/fastsurfer/kinderseg/scripts/run_fastsurfer_volstats.sh" "$sub" "$threads"


#  python environment + python scirpt
python "/fastsurfer/kinderseg/scripts/data_processing.py" "$sub"



echo "========================================"
source /opt/miniconda/etc/profile.d/conda.sh
conda activate R_kinderseg

Rscript "/fastsurfer/kinderseg/scripts/data_analysis.R" "$sub" "$age"



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
