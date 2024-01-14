#This is the pipeline to  decontaminating" some small-RNA samples from a couple of mouse strains

#1. download all the required files 

# Specify the list of URLs
list_of_urls="/home/mariana/Linux_entregable/decont/data/urls"

# Download all the files specified in the list_of_urls
for url in $(<"$list_of_urls"); do
    output_file="/home/mariana/Linux_entregable/decont/data/$(basename $url)"
    
    # Check if the output file already exists
    if [ -e "$output_file" ]; then
        echo "Output file for $url already exists. Skipping the download."
    else
        bash download.sh "/home/mariana/Linux_entregable/decont/data/urls" \
            "/home/mariana/Linux_entregable/decont/data" "exclude_keyword"
    fi
done

# Download the nts fasta file, uncompress it, and filter to remove all small nuclear RNAs
contaminants_output_file="/home/mariana/Linux_entregable/decont/res/contaminants.fasta"

# Check if the output file already exists
if [ -e "$contaminants_output_file" ]; then
    echo "Output file for contaminants.fasta already exists. Skipping the download."
else
    bash download.sh "/home/mariana/Linux_entregable/decont/data/cont" \
        "/home/mariana/Linux_entregable/decont/res" yes # TODO
fi

#2. Index the contaminants file
contaminants_index="/home/mariana/Linux_entregable/decont/res/contaminants_idx"

# Check if the output directory already exists
if [ -e "$contaminants_index" ]; then
    echo "Output directory for contaminants index already exists. Skipping indexing."
else
    bash index.sh "/home/mariana/Linux_entregable/decont/res/contaminants.fasta" \
        "/home/mariana/Linux_entregable/decont/res/contaminants_idx"
fi

#3.  Merge the samples into a single file
list_of_samples="/home/mariana/Linux_entregable/decont/data/*.fastq.gz"
output_directory="/home/mariana/Linux_entregable/decont/out/merged"

# Create Directories if They Don't Exist
mkdir -p "$output_directory"

for sample_file in $list_of_samples; do
    sample_id=$(basename "$sample_file" | cut -d'_' -f1)
    bash merge_fastqs.sh "$sample_file" "$output_directory" "$sample_id"
done

#create the new file for the log.out 
touch "$log.out"

# create a directory and a file for the log cutadapt and  log star files 
main_log_file="/home/mariana/Linux_entregable/decont/log/log.out"
log_directory="/home/mariana/Linux_entregable/decont/log/cutadapt"
trimmed_directory="/home/mariana/Linux_entregable/decont/out/trimmed"

# Create Directories if They Don't Exist
mkdir -p "$log_directory"
mkdir -p "$trimmed_directory"

#4.  Run cutadapt for all merged files
for merged_file in "$output_directory"/*.fastq.gz; do
    sample_id=$(basename "$merged_file" | cut -d'_' -f1)
    trimmed_file="${trimmed_directory}/${sample_id}_trimmed.fastq.gz"
    log_file="${log_directory}/${sample_id}.log"

    # Check if the output file already exists
    if [ -e "$trimmed_file" ]; then
        echo "Output file for $sample_id already exists. Skipping the cutadapt operation."
    else
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
            -o "$trimmed_file" "$merged_file" > "$log_file"

        # Append information to the main log file
        echo "=== Cutadapt Log for $sample_id ===" >> "$main_log_file"
        grep "Reads with adapters" "$log_file" >> "$main_log_file"
        grep "Total basepairs processed" "$log_file" >> "$main_log_file"
    fi
done

#Variables for STAR
contaminants_index="/home/mariana/Linux_entregable/decont/res/contaminants_idx"
star_output_directory="/home/mariana/Linux_entregable/decont/out/star"

#5.  run STAR for all trimmed files
for trimmed_file in "$trimmed_directory"/*.fastq.gz; do
    sample_id=$(basename "$trimmed_file" | cut -d'_' -f1)
    star_output_dir="$star_output_directory/$sample_id"

    # Check if the output directory already exists
    if [ -e "$star_output_dir" ]; then
        echo "Output directory for STAR already exists. Skipping STAR operation for $sample_id."
    else
        mkdir -p "$star_output_directory/$sample_id" 

        # Run STAR and append relevant information to the temporary log file
        STAR --runThreadN 4 --genomeDir "$contaminants_index" \
            --outReadsUnmapped Fastx --readFilesIn "$trimmed_file" \
            --readFilesCommand gunzip -c --outFileNamePrefix "$star_output_dir/" \
        2>&1 | tee -a "$log_file"

        # Append information from STAR logs to the main log file
        echo "=== STAR Log for $sample_id ===" >> "$main_log_file"
        grep "Uniquely mapped reads %" "$log_file" >> "$main_log_file"
        grep "% of reads mapped to multiple loci" "$log_file" >> "$main_log_file"
        grep "% of reads mapped to too many loci" "$log_file" >> "$main_log_file"
    fi
done
