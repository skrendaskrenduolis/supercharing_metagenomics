#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J compression_level_benchmark_new
### -- ask for number of cores (default: 1) -- 
#BSUB -n 1 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need N GB of memory per core/slot -- 
#BSUB -R "rusage[mem=25GB]"
### -- specify that we want the job to get killed if it exceeds 20 GB per core/slot -- 
#BSUB -M 25GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 10:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo compression_level_benchmark_new.out 
#BSUB -eo compression_level_benchmark_new.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

# here follow the commands you want to execute with input.in as the input file

# activating conda env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

# 8.1 GB file is compressed with gzip levels 1 to 9 (lowest to highest)


for i in {1..9}
do
    touch $(pwd)/decompression_times_compression_level_${i}.txt
    gzip -$i -c /dev/shm/temp_test_file.fastq > /dev/shm/compressed_file_$i.fastq.gz
    
    # the file is then repeatedly decompressed into /dev/null and time is measured
    for j in {1..20}
    do
        /usr/bin/time -v -o $(pwd)/decompression_times_compression_level_${i}.txt -a gunzip -c /dev/shm/compressed_file_$i.fastq.gz > /dev/null

        sleep 5
    done

    rm "/dev/shm/compressed_file_${i}.fastq.gz"
done

rm "/dev/shm/temp_test_file.fastq"

conda deactivate
