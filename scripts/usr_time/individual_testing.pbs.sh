#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J isolation_tests_new
### -- ask for number of cores (default: 1) -- 
#BSUB -n 1 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=30GB]"
### -- specify that we want the job to get killed if it exceeds 9 GB per core/slot -- 
#BSUB -M 30GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 10:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo isolation_tests_new.out 
#BSUB -eo isolation_tests_new.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics


touch fastp_isolated_time_1GB.txt
touch kma_isolated_time_1GB.txt
touch samtools_view_sort_isolated_time_1GB.txt
touch bcftools_mpileup_isolated_time_1GB.txt
touch bcftools_call_isolated_time_1GB.txt
touch bcftools_norm_isolated_time_1GB.txt
touch bcftools_filter_isolated_time_1GB.txt

for i in {1..20}
do
    mkdir /dev/shm/kma_output

    /usr/bin/time -v -o fastp_isolated_time_1GB.txt -a fastp -w 1 -i ~/main_folder/data/raw/1GB_1.fastq.gz -I ~/main_folder/data/raw/1GB_2.fastq.gz --stdout > /dev/shm/fastp_output_trim.fastq
    
    /usr/bin/time -v -o kma_isolated_time_1GB.txt -a kma -t 1 -int /dev/shm/fastp_output_trim.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    samtools view -u /dev/shm/output.sam | /usr/bin/time -v -o samtools_view_sort_isolated_time_1GB.txt -a samtools sort - -u -o /dev/shm/output_sorted.sam

    /usr/bin/time -v -o bcftools_mpileup_isolated_time_1GB.txt -a bcftools mpileup /dev/shm/output_sorted.sam -A -Ou -o /dev/shm/output.vcf  -f ~/main_folder/databases/resfinder_db/all.fsa 

    /usr/bin/time -v -o bcftools_call_isolated_time_1GB.txt -a bcftools call /dev/shm/output.vcf --ploidy 1 -mv -Ou -o /dev/shm/output_calls.vcf 

    /usr/bin/time -v -o bcftools_norm_isolated_time_1GB.txt -a bcftools norm /dev/shm/output_calls.vcf -f ~/main_folder/databases/resfinder_db/all.fsa -Ou -o /dev/shm/output_calls_norm.vcf 

    /usr/bin/time -v -o bcftools_filter_isolated_time_1GB.txt -a bcftools view /dev/shm/output_calls_norm.vcf -i 'QUAL>=20' -Ob -o /dev/shm/output_calls_norm.bcf

    rm /dev/shm/fastp_output_trim.fastq /dev/shm/output.sam /dev/shm/output_sorted.sam /dev/shm/output.vcf /dev/shm/output_calls.vcf /dev/shm/output_calls_norm.vcf /dev/shm/output_calls_norm.bcf
    rm -r /dev/shm/kma_output

    sleep 5
done

###########################################################
touch fastp_isolated_time_5GB.txt
touch kma_isolated_time_5GB.txt
touch samtools_view_sort_isolated_time_5GB.txt
touch bcftools_mpileup_isolated_time_5GB.txt
touch bcftools_call_isolated_time_5GB.txt
touch bcftools_norm_isolated_time_5GB.txt
touch bcftools_filter_isolated_time_5GB.txt

for i in {1..20}
do
    mkdir /dev/shm/kma_output

    /usr/bin/time -v -o fastp_isolated_time_5GB.txt -a fastp -w 1 -i ~/main_folder/data/raw/5GB_1.fastq.gz -I ~/main_folder/data/raw/5GB_2.fastq.gz --stdout > /dev/shm/fastp_output_trim.fastq
    
    /usr/bin/time -v -o kma_isolated_time_5GB.txt -a kma -t 1 -int /dev/shm/fastp_output_trim.fastq -o /dev/shm/kma_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    samtools view -u /dev/shm/output.sam | /usr/bin/time -v -o samtools_view_sort_isolated_time_5GB.txt -a samtools sort - -u -o /dev/shm/output_sorted.sam

    /usr/bin/time -v -o bcftools_mpileup_isolated_time_5GB.txt -a bcftools mpileup /dev/shm/output_sorted.sam -A -Ou -o /dev/shm/output.vcf  -f ~/main_folder/databases/resfinder_db/all.fsa 

    /usr/bin/time -v -o bcftools_call_isolated_time_5GB.txt -a bcftools call /dev/shm/output.vcf --ploidy 1 -mv -Ou -o /dev/shm/output_calls.vcf 

    /usr/bin/time -v -o bcftools_norm_isolated_time_5GB.txt -a bcftools norm /dev/shm/output_calls.vcf -f ~/main_folder/databases/resfinder_db/all.fsa -Ou -o /dev/shm/output_calls_norm.vcf 

    /usr/bin/time -v -o bcftools_filter_isolated_time_5GB.txt -a bcftools view /dev/shm/output_calls_norm.vcf -i 'QUAL>=20' -Ob -o /dev/shm/output_calls_norm.bcf

    rm /dev/shm/fastp_output_trim.fastq /dev/shm/output.sam /dev/shm/output_sorted.sam /dev/shm/output.vcf /dev/shm/output_calls.vcf /dev/shm/output_calls_norm.vcf /dev/shm/output_calls_norm.bcf
    rm -r /dev/shm/kma_output

    sleep 5
done

conda deactivate
