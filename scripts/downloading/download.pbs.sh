#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J sra_data_download
### -- ask for number of cores (default: 1) -- 
#BSUB -n 8
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 1GB of memory per core/slot -- 
#BSUB -R "rusage[mem=1GB]"
### -- specify that we want the job to get killed if it exceeds 2 GB per core/slot -- 
#BSUB -M 2GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 10:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -o sra_data_download.out 
#BSUB -e sra_data_download.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonE5_2660v3]"

# here follow the commands you want to execute with input.in as the input file

# activating conda env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

# iterate over accessions and download
for accession in SRR7992574 ERR1884262 SRR3434587
do
    parallel-fastq-dump --sra-id $accession --threads 8 --outdir ~/main_folder/data/raw/ --gzip
done

conda deactivate
