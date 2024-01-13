#Script to download the data

#Assign the variables 

# absolute path for the provided file
url_file="$(realpath "$1")"
destination_directory="$(realpath "$2")"
uncompress=$3
exclude_keyword=$4
expected_md5=$5


# Look for a file named 'urls' in the destination directory
url_file="$destination_directory/urls"

#Create a  the directory for the downloaded data, as for this exercise we already have the data directory i set the pathway in the variable 
mkdir -p "$destination_directory"


# Download the files listed in the URL file
wget -i "$url_file" -P "$destination_directory"


# Function to calculate MD5 checksum for a file
calculate_md5() {
    md5sum "$1" | awk '{print $1}'
}


# Loop through the downloaded files to uncompress, filter and check the MD5

for filepath in "$destination_directory"/*; do
    # Check if uncompress flag is set to "yes"
    if [ "$uncompress" == "yes" ]; then
        gunzip "$filepath"
        filepath="${filepath%.gz}"  
    fi

# Calculate MD5 checksum for the downloaded file
    calculated_md5=$(calculate_md5 "$filepath")


# Compare MD5 checksums if an expected MD5 is provided
    if [ -n "$expected_md5" ] && [ "$calculated_md5" != "$expected_md5" ]; then
        echo "Error: MD5 checksum mismatch for $(basename "$filepath"). Aborting."
        exit 1
    fi

    # Check if exclude keyword is provided
    if [ -n "$exclude_keyword" ]; then
        grep -v "$exclude_keyword" "$filepath" > "$destination_directory/filtered_$(basename "$filepath")"
        mv "$destination_directory/filtered_$(basename "$filepath")" "$filepath"
    fi

    # Check for the corresponding MD5 file
    md5_file="$filepath.md5"
    if [ -f "$md5_file" ]; then
        # Calculate MD5 checksum for the downloaded file
        calculated_md5=$(calculate_md5 "$filepath")

        # Compare MD5 checksums
        if [ "$calculated_md5" != "$(cat "$md5_file")" ]; then
            echo "Error: MD5 checksum mismatch for $(basename "$filepath"). Aborting."
            exit 1
        fi
    fi
done


echo "Download completed. Files saved in '$destination_directory'."




# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
