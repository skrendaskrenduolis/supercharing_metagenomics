#!/bin/sh
### General options
### –- specify queue --
#BSUB -q gpua100
### -- set the job Name --
#BSUB -J barracuda-ecoli-pipe
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
#BSUB -o barracuda-ecoli-pipe.out
#BSUB -e barracuda-ecoli-pipe.err
# -- end of LSF options --

# nvidia-smi
# Load the cuda module
module load cuda/11.0
module load gcc/4.8.5

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics
cd ~/barracuda/bin/

# test 1
# # fastp input is prepared first, followed by barracuda at various cpu thread counts
# # first ecoli then metagenome. Metagenome reads are untrimmed to preserve read length and maintain file size consistent with other tests
fastp -w 8 -i ~/main_folder/data/raw/SRR15334628_1.fastq.gz -I ~/main_folder/data/raw/SRR15334628_2.fastq.gz -o /dev/shm/ecoli_pipe_1.fastq -O /dev/shm/ecoli_pipe_2.fastq --length_required 200 -b 200 -B 200 

for i in 1 2 4 8 16
do 
    ecoli_time_file=~/main_folder/data/experiment_raw/gpu_times/barracuda_ecoli_pipe_times_$i.txt

    touch $ecoli_time_file

    for j in {1..5}
    do  
        #just a single sampling run from the 20
        if [[ "$j" -eq 1 ]]; then
            ecoli_nvidia_smi_filename=~/main_folder/data/experiment_raw/gpu_times/barracuda_ecoli_pipe_nvidiasmi_$i.txt
            nvidia-smi --query-gpu=timestamp,name,pci.bus_id,driver_version,pstate,pcie.link.gen.max,pcie.link.gen.current,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used -i 0 --format=csv -l 1 > $ecoli_nvidia_smi_filename &
        fi

        /usr/bin/time -v -o $ecoli_time_file -a -p bash -c "barracuda sampe -t $i ~/main_folder/databases/ecoli_genome_bwt/GCA_018185575.1.fasta <(barracuda aln ~/main_folder/databases/ecoli_genome_bwt/GCA_018185575.1.fasta /dev/shm/ecoli_pipe_1.fastq) <(barracuda aln ~/main_folder/databases/ecoli_genome_bwt/GCA_018185575.1.fasta /dev/shm/ecoli_pipe_2.fastq) /dev/shm/ecoli_pipe_1.fastq /dev/shm/ecoli_pipe_2.fastq | samtools view -F 4 /dev/stdin > /dev/shm/barracuda_ecoli_pipe.sam"
        rm /dev/shm/barracuda_ecoli_pipe.sam
        rm /dev/shm/ecoli_pipe_1.sai
        rm /dev/shm/ecoli_pipe_2.sai
        
        # kill the process
        if [[ "$j" -eq 1 ]]; then
            pkill nvidia-smi  
        fi
        
        sleep 5

    done
done
