#!/bin/sh
### General options
### –- specify queue --
#BSUB -q gpua100
### -- set the job Name --
#BSUB -J barracuda-metagenome
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- ask for number of cores (default: 1) --
#BSUB -n 16
### -- Select the resources: 1 gpu in exclusive process mode --
#BSUB -gpu "num=1:mode=exclusive_process"
### -- set walltime limit: hh:mm --  maximum 24 hours for GPU-queues right now
#BSUB -W 06:00
# request 3GB of system-memory
#BSUB -R "rusage[mem=3GB]"
### -- specify that we want the job to get killed if it exceeds 3 GB per core/slot -- 
#BSUB -M 3GB
### -- Specify the output and error file. %J is the job-id --
### -- -o and -e mean append, -oo and -eo mean overwrite --
#BSUB -o barracuda-metagenome.out
#BSUB -e barracuda-metagenome.err
# -- end of LSF options --

nvidia-smi
# Load the cuda module
module load cuda/11.0
module load gcc/4.8.5

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics
cd ~/barracuda/bin/

# test 1
# # fastp input is prepared first, followed by barracuda at various cpu thread counts
# # first ecoli then metagenome. Metagenome reads are untrimmed to preserve read length and maintain file size consistent with other tests
gunzip -c ~/main_folder/data/raw/1GB_1.fastq.gz > /dev/shm/1GB_1.fastq
gunzip -c ~/main_folder/data/raw/1GB_2.fastq.gz > /dev/shm/1GB_2.fastq

for i in 1 2 4 8 16
do 
    metagenome_time_file=~/main_folder/data/experiment_raw/gpu_times/barracuda_metagenome_times_$i.txt

    touch $metagenome_time_file

    for j in {1..5}
    do  
        # just a single sampling run from the 20
        if [[ "$j" -eq 1 ]]; then
            metagenome_nvidia_smi_filename=~/main_folder/data/experiment_raw/gpu_times/barracuda_metagenome_nvidiasmi_$i.txt
            nvidia-smi --query-gpu=timestamp,name,pci.bus_id,driver_version,pstate,pcie.link.gen.max,pcie.link.gen.current,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used -i 0 --format=csv -l 1 > $metagenome_nvidia_smi_filename &
        fi

        /usr/bin/time -v -o $metagenome_time_file -a -p bash -c "barracuda aln ~/main_folder/databases/resfinder_bwt/all.fsa /dev/shm/1GB_1.fastq > /dev/shm/metagnome_1.sai ; \
        barracuda aln ~/main_folder/databases/resfinder_bwt/all.fsa /dev/shm/1GB_2.fastq > /dev/shm/metagenome_2.sai ; \
        barracuda sampe -t $i ~/main_folder/databases/resfinder_bwt/all.fsa /dev/shm/metagnome_1.sai /dev/shm/metagenome_2.sai /dev/shm/1GB_1.fastq /dev/shm/1GB_2.fastq \
        | samtools view -F 4 /dev/stdin > /dev/shm/barracuda_metagenome.sam"
        rm /dev/shm/barracuda_metagenome.sam
        
        # kill the process
        if [[ "$j" -eq 1 ]]; then
            pkill nvidia-smi  
        fi
        
        sleep 5

    done
done
