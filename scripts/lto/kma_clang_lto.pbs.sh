#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J kma_clang_lto
### -- ask for number of cores (default: 1) -- 
#BSUB -n 3 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=5GB]"
### -- specify that we want the job to get killed if it exceeds 9 GB per core/slot -- 
#BSUB -M 5GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 05:00 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo kma_clang_lto.out 
#BSUB -eo kma_clang_lto.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6226R]"

#load gcc and set source
module load gcc/13.1.0-binutils-2.40



source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics


# prepare input files (interleaved) and kma output folder
fastp -i ~/main_folder/data/raw/1GB_1.fastq.gz -I ~/main_folder/data/raw/1GB_2.fastq.gz --stdout > /dev/shm/metagenome_fastp_output.fastq
fastp -i ~/main_folder/data/raw/SRR15334628_1.fastq.gz -I ~/main_folder/data/raw/SRR15334628_2.fastq.gz --length_required 200 -b 200 -B 200 --stdout > /dev/shm/ecoli_fastp_output.fastq

# # compile kma with gcc
# cd kma/
# make -j 3 -f Makefile_gcc clean
# make -j 3 -f Makefile_gcc
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_time_metagenome.txt
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_time_ecoli.txt

# # run kma with metagenome input
# for i in {1..20}
# do
#     mkdir /dev/shm/metagenome_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_time_metagenome.txt -a kma-original -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/metagenome_output

#     sleep 5
# done

# mkdir /dev/shm/metagenome_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_metagenome_record.out kma-original -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/metagenome_output
# sleep 5



# # run kma with ecoli input
# for i in {1..20}
# do
#     mkdir /dev/shm/ecoli_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_time_ecoli.txt -a kma-original -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/ecoli_output

#     sleep 5
# done

# mkdir /dev/shm/ecoli_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_gcc_ecoli_record.out kma-original -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/ecoli_output
# sleep 5




# ###############################################
# # clang no lto
# module unload gcc/13.1.0-binutils-2.40
# module load clang/18.1.4-cuda-12.2.2

# cd ../kma-clang/
# make -j 3 -f Makefile_clang clean
# make -j 3 -f Makefile_clang
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_time_metagenome.txt
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_time_ecoli.txt

# # run kma with metagenome input
# for i in {1..20}
# do
#     mkdir /dev/shm/metagenome_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_time_metagenome.txt -a kma-clang -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/metagenome_output

#     sleep 5
# done

# mkdir /dev/shm/metagenome_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_metagenome_record.out kma-clang -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/metagenome_output
# sleep 5



# # run kma with ecoli input
# for i in {1..20}
# do
#     mkdir /dev/shm/ecoli_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_time_ecoli.txt -a kma-clang -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/ecoli_output

#     sleep 5
# done

# mkdir /dev/shm/ecoli_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_ecoli_record.out kma-clang -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/ecoli_output
# sleep 5



# #################################################
# # clang with lto
# cd ../kma-clang-lto/
# make -j 3 -f Makefile_clang_lto clean
# make -j 3 -f Makefile_clang_lto
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_time_metagenome.txt
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_time_ecoli.txt

# # run kma with metagenome input
# for i in {1..20}
# do
#     mkdir /dev/shm/metagenome_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_time_metagenome.txt -a kma-clang-lto -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/metagenome_output

#     sleep 5
# done

# mkdir /dev/shm/metagenome_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_metagenome_record.out kma-clang-lto -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/metagenome_output
# sleep 5



# # run kma with ecoli input
# for i in {1..20}
# do
#     mkdir /dev/shm/ecoli_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_time_ecoli.txt -a kma-clang-lto -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/ecoli_output

#     sleep 5
# done

# mkdir /dev/shm/ecoli_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_ecoli_record.out kma-clang-lto -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/ecoli_output
# sleep 5




# ################################
# # clang with lto and unroll loops
# cd ../kma-clang-lto-unroll/
# make -j 3 -f Makefile_clang_lto_unroll clean
# make -j 3 -f Makefile_clang_lto_unroll
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_time_metagenome.txt
# touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_time_ecoli.txt

# # run kma with metagenome input
# for i in {1..20}
# do
#     mkdir /dev/shm/metagenome_output
    
#     /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_time_metagenome.txt -a kma-clang-lto-unroll -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/metagenome_output

#     sleep 5
# done

# mkdir /dev/shm/metagenome_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_metagenome_record.out kma-clang-lto-unroll -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/metagenome_output
# sleep 5



# # run kma with ecoli input
# for i in {1..20}
# do
#     mkdir /dev/shm/ecoli_output
    
#     /usr/bin/time -v -o kma_clang_lto_unroll_time_ecoli.txt -a kma-clang-lto-unroll -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

#     rm /dev/shm/output.sam
#     rm -r /dev/shm/ecoli_output

#     sleep 5
# done

# mkdir /dev/shm/ecoli_output
# perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ecoli_record.out kma-clang-lto-unroll -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
# rm /dev/shm/output.sam
# rm -r /dev/shm/ecoli_output
# sleep 5




# ####################################################
# clang lto unroll loops ofast
cd ../kma-clang-lto-unroll-ofast/
make -j 3 -f Makefile_clang_lto_unroll_ofast clean
make -j 3 -f Makefile_clang_lto_unroll_ofast
touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ofast_time_metagenome.txt
touch ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ofast_time_ecoli.txt

# run kma with metagenome input
for i in {1..20}
do
    mkdir /dev/shm/metagenome_output
    
    /usr/bin/time -v -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ofast_time_metagenome.txt -a kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    rm /dev/shm/output.sam
    rm -r /dev/shm/metagenome_output

    sleep 5
done

mkdir /dev/shm/metagenome_output
perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ofast_metagenome_record.out kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
rm /dev/shm/output.sam
rm -r /dev/shm/metagenome_output
sleep 5



# run kma with ecoli input
for i in {1..20}
do
    mkdir /dev/shm/ecoli_output
    
    /usr/bin/time -v -o kma_clang_lto_unroll_ofast_time_ecoli.txt -a kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    rm /dev/shm/output.sam
    rm -r /dev/shm/ecoli_output

    sleep 5
done

mkdir /dev/shm/ecoli_output
perf record -e resource_stalls.any -e cycle_activity.stalls_total -e cycles -g -o ~/main_folder/data/experiment_raw/clang_tests/kma_clang_lto_unroll_ofast_ecoli_record.out kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
rm /dev/shm/output.sam
rm -r /dev/shm/ecoli_output
sleep 5


rm /dev/shm/metagenome_fastp_output.fastq
rm /dev/shm/ecoli_fastp_output.fastq
conda deactivate
