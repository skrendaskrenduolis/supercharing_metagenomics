#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J blend_perf
### -- ask for number of cores (default: 1) -- 
#BSUB -n 3
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=5GB]"
### -- specify that we want the job to get killed if it exceeds 2 GB per core/slot -- 
#BSUB -M 5GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 01:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo blend_perf.out 
#BSUB -eo blend_perf.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

module load gcc/13.1.0-binutils-2.40

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

cd ~/blend/bin/

fastp -w 3 -i ~/main_folder/data/raw/SRR15334628_1.fastq.gz -I ~/main_folder/data/raw/SRR15334628_2.fastq.gz --length_required 200 -b 200 -B 200 --stdout > /dev/shm/ecoli_trimmed_kma.fastq

ecoli_record_file=~/main_folder/data/experiment_raw/gpu_times/blend_ecoli_record.out

perf record -e cycles -e resource_stalls.any -e cycle_activity.stalls_total -g -o $ecoli_record_file blend -ax sr -t 1 ~/main_folder/databases/ecoli_genome/GCA_018185575.1.fasta /dev/shm/ecoli_trimmed_kma.fastq > /dev/shm/ecoli_blend.sam 
rm /dev/shm/ecoli_blend.sam
sleep 5 
