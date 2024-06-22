#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J 9.5GB_unzip_size
### -- ask for number of cores (default: 1) -- 
#BSUB -n 1 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need N GB of memory per core/slot -- 
#BSUB -R "rusage[mem=100GB]"
### -- specify that we want the job to get killed if it exceeds 1 GB per core/slot -- 
#BSUB -M 100GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 04:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo 9.5GB_unzip_size.out 
#BSUB -eo 9.5GB_unzip_size.err
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6342]"

# here follow the commands you want to execute with input.in as the input file

# activating conda env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

filename="9.5GB"

touch $(pwd)/$filename.unzipped_size.txt

/usr/bin/time -v -o $(pwd)/$filename.unzipped_size.txt -a gunzip -c ~/main_folder/data/raw/$filename.fastq.gz > /dev/shm/$filename.fastq

ls -lh /dev/shm | cat >> $(pwd)/$filename.unzipped_size.txt

rm "/dev/shm/$filename.fastq"

conda deactivate
