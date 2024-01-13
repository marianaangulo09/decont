#Script to download the data

#Assign the variables 

# absolute path for the provided file
url_file="$(realpath "$1")"
destination_directory="/home/mariana/Linux_entregable/decont/data"
uncompress=$3
exclude_keyword=$4
expected_md5=$5

#Create a  the directory for the downloaded data, as for this exercise we already have the data directory i set the pathway in the variable 
mkdir -p "$destination_directory"


# Download the files listed in the URL file
wget -i "$url_file" -P "$destination_directory"


# Function to calculate MD5 checksum for a file
calculate_md5() {
    md5sum "$1" | awk '{print $1}'
}















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
