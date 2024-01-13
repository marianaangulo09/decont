
#Download all the files specified in data/filenames
#For download.sh you can add 4 arguments 1:path were the url file is, 2: the path of the directory to store the downloaded files, 3:option yes to uncompress, 4: specific word to filter

# Specify the list of URLs
list_of_urls="/home/mariana/Linux_entregable/decont/data/urls"

# Download all the files specified in the list_of_urls
for url in $(<"$list_of_urls"); do
    bash download.sh "/home/mariana/Linux_entregable/decont/data/urls" "/home/mariana/Linux_entregable/decont/data"  yes "exclude_keyword" 
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs

bash download.sh "/home/mariana/Linux_entregable/decont/data/cont" "/home/mariana/Linux_entregable/decont/res"  yes #TODO

# Index the contaminants file
bash index.sh "/home/mariana/Linux_entregable/decont/res/contaminants.fasta" "/home/mariana/Linux_entregable/decont/res/contaminants_idx"


# Merge the samples into a single file
for file in /home/mariana/Linux_entregable/decont/data/*.fastq; do
    sample_id=$(basename "$file" | cut -d'_' -f1)
    bash merge_fastqs.sh "$file" "/home/mariana/Linux_entregable/decont/out" "$sample_id"
done


# TODO: run cutadapt for all merged files
# cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
#     -o <trimmed_file> <input_file> > <log_file>

# TODO: run STAR for all trimmed files
#for fname in out/trimmed/*.fastq.gz
#do
    # you will need to obtain the sample ID from the filename
 #   sid=#TODO
    # mkdir -p out/star/$sid
    # STAR --runThreadN 4 --genomeDir res/contaminants_idx \
    #    --outReadsUnmapped Fastx --readFilesIn <input_file> \
    #    --readFilesCommand gunzip -c --outFileNamePrefix <output_directory>
#done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
