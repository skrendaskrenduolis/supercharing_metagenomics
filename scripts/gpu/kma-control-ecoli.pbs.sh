#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J kma_control_ecoli
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
#BSUB -oo kma_control_ecoli.out 
#BSUB -eo kma_control_ecoli.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"


module load gcc/13.1.0-binutils-2.40

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics
cd kma-default
make clean
make -j 8

# test 1
# # fastp input is prepared first, followed by bwa-gasal at various cpu thread counts
# # first ecoli then metagenome. Metagenome reads are untrimmed to preserve read length and maintain file size consistent with other tests
fastp -w 8 -i ~/main_folder/data/raw/SRR15334628_1.fastq.gz -I ~/main_folder/data/raw/SRR15334628_2.fastq.gz --length_required 200 -b 200 -B 200 --stdout > /dev/shm/ecoli_trimmed_kma.fastq


# test 3 
# # kma without piping at various threads for ecoli and metagenome

for i in 1 2 4 8 16
do 
    ecoli_time_file=~/main_folder/data/experiment_raw/gpu_times/kma_ecoli_times_$i.txt

    touch $ecoli_time_file

    for j in {1..5}
    do
        mkdir /dev/shm/kma_output
        /usr/bin/time -v -o $ecoli_time_file -a kma -t $i -int /dev/shm/ecoli_trimmed_kma.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome -ef -cge -nf -sam 4 > /dev/shm/ecoli_kma.sam 
        rm /dev/shm/ecoli_kma.sam
        rm -r /dev/shm/kma_output
        sleep 5 

    done
done
