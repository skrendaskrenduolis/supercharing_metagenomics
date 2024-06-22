#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J gunzip_benchmarking_new
### -- ask for number of cores (default: 1) -- 
#BSUB -n 1 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need N GB of memory per core/slot -- 
#BSUB -R "rusage[mem=6GB]"
### -- specify that we want the job to get killed if it exceeds 30 GB per core/slot -- 
#BSUB -M 6GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 24:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -o gunzip_benchmarking_new.out 
#BSUB -e gunzip_benchmarking_new.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

# here follow the commands you want to execute with input.in as the input file

# activating conda env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

# for each file size
for filename in 1GB_1.fastq.gz 5GB_1.fastq.gz
do

    # create file to keep time
    touch $(pwd)/$filename.gzip_timing.txt

    # read file to tmpfs from disk
    cp ~/main_folder/data/raw/$filename /dev/shm/$filename.gunzip.benchmark

    # 50 iterations
    for i in {1..20}
    do
        # 100 gunzip iterations to measure time
        /usr/bin/time -v -o $(pwd)/$filename.gzip_timing.txt -a gunzip -c /dev/shm/$filename.gunzip.benchmark > /dev/null

        sleep 5
    done

    # remove from tmpfs
    rm "/dev/shm/$filename.gunzip.benchmark"

done

conda deactivate
