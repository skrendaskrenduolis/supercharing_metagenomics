#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J kma_control_metagenome
### -- ask for number of cores (default: 1) -- 
#BSUB -n 16
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=3GB]"
### -- specify that we want the job to get killed if it exceeds 2 GB per core/slot -- 
#BSUB -M 3GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 04:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo kma_control_metagenome.out 
#BSUB -eo kma_control_metagenome.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"


module load gcc/4.8.5
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics
cd kma-default
make clean
make -j 8

# test 1
# # fastp input is prepared first, followed by bwa-gasal at various cpu thread counts
# # first ecoli then metagenome. Metagenome reads are untrimmed to preserve read length and maintain file size consistent with other tests
gunzip -c ~/main_folder/data/raw/1GB_1.fastq.gz > /dev/shm/1GB_1_kma.fastq
gunzip -c ~/main_folder/data/raw/1GB_2.fastq.gz > /dev/shm/1GB_2_kma.fastq

# test 3 
# # kma without piping at various threads for ecoli and metagenome

for i in 1 2 4 8 16
do 
    metagenome_time_file=~/main_folder/data/experiment_raw/gpu_times/kma_metagenome_times_$i.txt

    touch $metagenome_time_file

    for j in {1..5}
    do

        mkdir /dev/shm/kma_output
        /usr/bin/time -v -o $metagenome_time_file -a kma -t $i -ipe /dev/shm/1GB_1_kma.fastq /dev/shm/1GB_2_kma.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder -ef -cge -nf -sam 4 > /dev/shm/metagenome_kma.sam
        rm /dev/shm/metagenome_kma.sam
        rm -r /dev/shm/kma_output

        sleep 5
    done
done
