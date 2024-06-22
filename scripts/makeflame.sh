#!/bin/sh
# perf script -i ../main_folder/data/experiment/kma_record_9.5GB.txt | ./stackcollapse-perf.pl > ../main_folder/data/experiment/kma_record_9.5GB.perf-folded
# cat ../main_folder/data/experiment/flamegraphs/kma_record_9.5GB.perf-folded | ./flamegraph.pl > ../main_folder/data/experiment/flamegraphs/kma_record_9.5GB.svg

names=($(ls -p ../main_folder/data/experiment/pipetest/ | grep -v / | grep record | gawk -F '[.]' '{ print $1"."$2 }'))
for name in ${names[@]}
do
    echo $name
    perf script -i ../main_folder/data/experiment/pipetest/$name.out | ./stackcollapse-perf.pl > ../main_folder/data/experiment/flamegraphs/$name.perf-folded
    cat ../main_folder/data/experiment/flamegraphs/$name.perf-folded | ./flamegraph.pl > ../main_folder/data/experiment/flamegraphs/$name.svg
done
