#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J kma_arch_native
### -- ask for number of cores (default: 1) -- 
#BSUB -n 1 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=12GB]"
### -- specify that we want the job to get killed if it exceeds 9 GB per core/slot -- 
#BSUB -M 12GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 01:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo kma_arch_native.out 
#BSUB -eo kma_arch_native.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

#load gcc and set source
module load gcc/13.1.0-binutils-2.40
source ~/miniconda3/bin/activate

# kma is first downloaded
if test -f $(pwd)/kma/Makefile; then
    rm -r $(pwd)/kma
fi 


if test -f ~/miniconda3/envs/metagenomics/bin/kma; then
    rm ~/miniconda3/envs/metagenomics/bin/kma
fi

# kma is first downloaded
git clone https://bitbucket.org/genomicepidemiology/kma.git

# enter folder, edit flags and compile
cd kma
sed -i 's/CFLAGS ?= -Wall -O3/CFLAGS ?= -Wall -O3 -g -march=native/g' Makefile
/usr/bin/time -v -o ../kma_O3_compile.txt make

# move bin to env bin folder
mv kma ~/miniconda3/envs/metagenomics/bin/
cd ..

#activate env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics

# prepare files
touch kma_isolated_time_O3_1GB.txt

fastp -w 1 -i ~/main_folder/data/raw/1GB_1.fastq.gz -I ~/main_folder/data/raw/1GB_2.fastq.gz --stdout > /dev/shm/fastp_output_trim.fastq


# run kma
for i in {1..20}
do
    mkdir /dev/shm/kma_output
    
    /usr/bin/time -v -o kma_isolated_time_O3_1GB.txt -a kma -t 1 -int /dev/shm/fastp_output_trim.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    rm /dev/shm/output.sam
    rm -r /dev/shm/kma_output

    sleep 5
done

rm /dev/shm/fastp_output_trim.fastq

conda deactivate

###########################################################
# repeat with -Ofast

if test -f $(pwd)/kma/Makefile; then
    rm -r $(pwd)/kma
fi 


if test -f ~/miniconda3/envs/metagenomics/bin/kma; then
    rm ~/miniconda3/envs/metagenomics/bin/kma
fi

# kma is first downloaded
git clone https://bitbucket.org/genomicepidemiology/kma.git

# enter folder, edit flags and compile
cd kma
sed -i 's/CFLAGS ?= -Wall -O3/CFLAGS ?= -Wall -Ofast -g -march=native/g' Makefile
/usr/bin/time -v -o ../kma_Ofast_compile.txt make

# move bin to env bin folder
mv kma ~/miniconda3/envs/metagenomics/bin/
cd ..

#activate env
conda activate ~/miniconda3/envs/metagenomics

# prepare files
touch kma_isolated_time_Ofast_1GB.txt

fastp -w 1 -i ~/main_folder/data/raw/1GB_1.fastq.gz -I ~/main_folder/data/raw/1GB_2.fastq.gz --stdout > /dev/shm/fastp_output_trim.fastq


# run kma
for i in {1..20}
do
    mkdir /dev/shm/kma_output
    
    /usr/bin/time -v -o kma_isolated_time_Ofast_1GB.txt -a kma -t 1 -int /dev/shm/fastp_output.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    rm /dev/shm/output.sam
    rm -r /dev/shm/kma_output

    sleep 5
done

rm /dev/shm/fastp_output_trim.fastq

##########################################################

# final kma delete
if test -f $(pwd)/kma/Makefile; then
    rm -r $(pwd)/kma
fi 


if test -f ~/miniconda3/envs/metagenomics/bin/kma; then
    rm "~/miniconda3/envs/metagenomics/bin/kma"
fi

conda deactivate
