
# Assign the input arguments to variables
samples_directory="$(realpath "$1")"
output_directory="$(realpath "$2")"
sample_id="$(realpath "$3")"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"


# Merge all files for the specified  sample id  into a single file
cat "$samples_directory/$sample_id"*.fastq > "$output_directory/$sample_id_merged.fastq"

echo "Merge completed. Merged file saved in '$output_directory'."




# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).
