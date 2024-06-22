#!/bin/sh
### General options
### –- specify queue --
#BSUB -q gpua100
### -- set the job Name --
#BSUB -J arioc-metagenome
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- ask for number of cores (default: 1) --
#BSUB -n 16
### -- Select the resources: 1 gpu in exclusive process mode --
#BSUB -gpu "num=1:mode=exclusive_process"
### -- set walltime limit: hh:mm --  maximum 24 hours for GPU-queues right now
#BSUB -W 08:00
# request 3GB of system-memory
#BSUB -R "rusage[mem=3GB]"
### -- specify that we want the job to get killed if it exceeds 3 GB per core/slot -- 
#BSUB -M 3GB
### -- Specify the output and error file. %J is the job-id --
### -- -o and -e mean append, -oo and -eo mean overwrite --
#BSUB -oo arioc-metagenome.out
#BSUB -eo arioc-metagenome.err
# -- end of LSF options --

# Load the cuda module
module load cuda/11.0
module load gcc/4.8.5

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics
cd ~/Arioc/bin

# test 1
# # fastp input is prepared first
# arioc encodes genomes (only done once so time is not measured)

metagenome_time_file=~/main_folder/data/experiment_raw/gpu_times/arioc_metagenome_times.txt
metagenome_index_time_file=~/main_folder/data/experiment_raw/gpu_times/arioc_metagenome_index_metagenome_times.txt

touch $metagenome_time_file
touch $metagenome_index_time_file
echo "time files done"

cp -r ~/main_folder/databases/resfinder_db /dev/shm/resfinder_db 
AriocE ~/Arioc/metagenome_configs/metagenome_reference.cfg
AriocE ~/Arioc/metagenome_configs/metagenome_reference_gap.cfg
echo "reference indexing done"


for j in {1..5}
do  
    mkdir /dev/shm/arioc_sam
    mkdir /dev/shm/metagenome_read_encodings

    fastp -w 8 -i ~/main_folder/data/raw/1GB_1.fastq.gz -I ~/main_folder/data/raw/1GB_2.fastq.gz -o /dev/shm/metagenome_read_encodings/metagenome_1.fastq -O /dev/shm/metagenome_read_encodings/metagenome_2.fastq
    # just a single sampling run from the 20
    if [[ "$j" -eq 1 ]]; then
        metagenome_nvidia_smi_filename=~/main_folder/data/experiment_raw/gpu_times/arioc_metagenome_nvidiasmi.txt
        nvidia-smi --query-gpu=timestamp,name,pci.bus_id,driver_version,pstate,pcie.link.gen.max,pcie.link.gen.current,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used -i 0 --format=csv -l 1 > $metagenome_nvidia_smi_filename &
    fi


    /usr/bin/time -v -o $metagenome_time_file -a AriocE ~/Arioc/metagenome_configs/metagenome_reads.cfg
    /usr/bin/time -v -o $metagenome_index_time_file -a AriocP ~/Arioc/metagenome_configs/metagenome_align.cfg
    
    # kill the process
    if [[ "$j" -eq 1 ]]; then
        pkill nvidia-smi  
    fi
    
    rm -r /dev/shm/arioc_sam
    rm -r /dev/shm/metagenome_read_encodings
    sleep 10

done
echo "read indexing + alignment done"

rm -r /dev/shm/metagenome_genome_arioc 
