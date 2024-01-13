# Assign the arguments to variables
genomefile="$(realpath "$1")"
outdir="$(realpath "$2")"

# Create the directory for the STAR index
mkdir -p "$outdir"


# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

# STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> \
# --genomeFastaFiles <genomefile> --genomeSAindexNbases 9
