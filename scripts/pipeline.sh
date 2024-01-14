
#Download all the files specified in data/filenames
#For download.sh you can add 4 arguments 1:path were the url file is, 2: the path of the directory to store the downloaded files, 3:option yes to uncompress, 4: specific word to filter

# Specify the list of URLs
list_of_urls="/home/mariana/Linux_entregable/decont/data/urls"

# Download all the files specified in the list_of_urls
for url in $(<"$list_of_urls"); do
    bash download.sh "/home/mariana/Linux_entregable/decont/data/urls" "/home/mariana/Linux_entregable/decont/data"  "exclude_keyword" 
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs

bash download.sh "/home/mariana/Linux_entregable/decont/data/cont" "/home/mariana/Linux_entregable/decont/res"  yes #TODO

# Index the contaminants file
bash index.sh "/home/mariana/Linux_entregable/decont/res/contaminants.fasta" "/home/mariana/Linux_entregable/decont/res/contaminants_idx"


# Merge the samples into a single file

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

# Set the path for the main log file
main_log_file="/home/mariana/Linux_entregable/decont/log/log.out"


#variables
log_directory="/home/mariana/Linux_entregable/decont/log/cutadapt"
trimmed_directory="/home/mariana/Linux_entregable/decont/out/trimmed"


# Create Directories if They Don't Exist
mkdir -p "$log_directory"
mkdir -p "$trimmed_directory"


# Run cutadapt for all merged files


for merged_file in "$output_directory"/*.fastq.gz; do
    sample_id=$(basename "$merged_file" | cut -d'_' -f1)
    trimmed_file="${trimmed_directory}/${sample_id}_trimmed.fastq.gz"
    log_file="${log_directory}/${sample_id}.log"

    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o "$trimmed_file" "$merged_file" > "$log_file"

#for filtering in the main log file

echo "=== Cutadapt Log for $sample_id ===" >> "$main_log_file"
    grep "Reads with adapters" "$log_file" >> "$main_log_file"
    grep "Total basepairs processed" "$log_file" >> "$main_log_file"

done

#Variables for STAR
contaminants_index="/home/mariana/Linux_entregable/decont/res/contaminants_idx"
star_output_directory="/home/mariana/Linux_entregable/decont/out/star"


mkdir -p "$star_output_directory"


# TODO: run STAR for all trimmed files

for trimmed_file in "$trimmed_directory"/*.fastq.gz; do
    sample_id=$(basename "$trimmed_file" | cut -d'_' -f1)

mkdir -p "$star_output_directory/$sample_id"

# Run STAR and append relevant information to the main log file


STAR --runThreadN 4 --genomeDir "$contaminants_index" \
    --outReadsUnmapped Fastx --readFilesIn "$trimmed_file" \
    --readFilesCommand gunzip -c --outFileNamePrefix "$output_directory/$sample_id" \
    2>&1 | tee -a "$log_file"


# Append information from STAR logs to the main log file
echo "=== STAR Log for $sample_id ===" >> "$main_log_file"
grep "Uniquely mapped reads %" "$log_file" >> "$main_log_file"
grep "% of reads mapped to multiple loci" "$log_file" >> "$main_log_file"
grep "% of reads mapped to too many loci" "$log_file" >> "$main_log_file"

done


# TODO: run STAR for all trimmed files
#for fname in out/trimmed/*.fastq.gz
#do
    # you will need to obtain the sample ID from the filename
 #   sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <outp1ut_directory>
#done 
# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
