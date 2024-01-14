
# Assign the input arguments to variables
samples_directory="$(realpath "$1")"
output_directory="$(realpath "$2")"
sample_id="$3"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Change to the samples directory
cd "$(dirname "$samples_directory")" || exit

# Merge all files for the specified sample ID into a single file
cat "${sample_id}"*.1.1s_sRNA.fastq.gz "${sample_id}"*.1.2s_sRNA.fastq.gz > "$output_directory"/"${sample_id}"_merged.fastq.gz


echo "Merge completed. Merged file saved in '$output_directory'."



# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).
