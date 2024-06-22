# compile kma with gcc
make -f Makefile_clang_lto_unroll_ofast
touch  ~/main_folder/data/experiment/clang_tests/kma_clang_lto_unroll_ofast_time_metagenome.txt
touch  ~/main_folder/data/experiment/clang_tests/kma_clang_lto_unroll_ofast_time_ecoli.txt

# run kma with metagenome input
for i in {1..20}
do
    mkdir /dev/shm/metagenome_output
    
    /usr/bin/time -v -o  ~/main_folder/data/experiment/clang_tests/kma_clang_lto_unroll_ofast_time_metagenome.txt -a kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam

    rm /dev/shm/output.sam
    rm -r /dev/shm/metagenome_output

    sleep 5
done

mkdir /dev/shm/metagenome_output
perf record -e resource_stalls.any -e cycle_activity.stalls_total -g -o  ~/main_folder/data/experiment/clang_tests/kma_clang_lto_unroll_ofast_metagenome_record.out kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/metagenome_fastp_output.fastq -o /dev/shm/metagenome_output/output -t_db ~/main_folder/databases/resfinder_db/ResFinder  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
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
perf record -e resource_stalls.any -e cycle_activity.stalls_total -g -o  ~/main_folder/data/experiment/clang_tests/kma_clang_lto_unroll_ofast_ecoli_record.out kma-clang-lto-unroll-ofast -t 1 -int /dev/shm/ecoli_fastp_output.fastq -o /dev/shm/ecoli_output/output -t_db ~/main_folder/databases/ecoli_genome/ecoli_genome  -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam
rm /dev/shm/output.sam
rm -r /dev/shm/ecoli_output
sleep 5


make -f Makefile_clang_lto_unroll_ofast clean

