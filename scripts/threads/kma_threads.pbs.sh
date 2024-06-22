#!/bin/sh 
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name -- 
#BSUB -J fastp_kma_runtime_test_run
### -- ask for number of cores (default: 1) -- 
#BSUB -n 8 
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 8GB of memory per core/slot -- 
#BSUB -R "rusage[mem=8GB]"
### -- specify that we want the job to get killed if it exceeds 9 GB per core/slot -- 
#BSUB -M 9GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 00:10 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -o Output_%J.out 
#BSUB -e Output_%J.err 
### -- Specify CPU model
#BSUB -R "select[model == XeonGold6342]"

# here follow the commands you want to execute with input.in as the input file

# activating conda env
source ~/miniconda3/bin/activate
conda activate ~/miniconda3/envs/metagenomics


# Use the 'ls' command with a pattern to list files ending with 'fastq.gz'
files=$(ls $(pwd)/../data/raw/*fastq.gz)
names_array=()

# Check if any matching files were found
if [ -z "$files" ]; then
  echo "No files found."
else
  # Iterate through the list of matching files and print each filename
  for file in $files; do
    filename=$(basename -s .fastq.gz $file)
    names_array+=("$filename")
  done

  echo ${names_array[@]}
  # loop to make all combinations of zipped/unzipped , write/pipe, and threads for fastp/kma
  for c in {zipped,unzipped}\ {pipe,write}\ {7,8}\ {7,8}; do
    words=()
    for i in $c; do
        words+=("$i") ;
    done
    echo "${words[@]}"
    
    # if zipped and write
    if [[ ${words[0]} = "zipped" && ${words[1]} = "write" ]]; then
      echo "running fastp for ${words[@]}"
      /usr/bin/time -v -o $(pwd)/../data/experiment/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt fastp -w ${words[2]} -i $(pwd)/../data/raw/${names_array[0]}.fastq.gz -I $(pwd)/../data/raw/${names_array[1]}.fastq.gz -o $(pwd)/../data/raw/${names_array[0]}_trimmed.fastq.gz -O $(pwd)/../data/raw/${names_array[1]}_trimmed.fastq.gz 
      echo "running kma for ${words[@]}"
      /usr/bin/time -v -o $(pwd)/../data/experiment/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt -a kma -t ${words[3]} -ipe $(pwd)/../data/raw/${names_array[0]}_trimmed.fastq.gz $(pwd)/../data/raw/${names_array[1]}_trimmed.fastq.gz -o ../resfinder_res/output -t_db ../databases/resfinder_db/ResFinder -1t1 -ef -cge -nf
      
      for name in "${names_array[@]}"; do
        rm "$(pwd)/../data/raw/${name}_trimmed.fastq.gz"
      done
      echo "5 second sleep"
      sleep 5
    fi
    
    # if unzipped and write
    # if [[ ${words[0]} = "unzipped" && ${words[1]} = "write" ]]; then
    #   echo "running fastp for ${words[@]}"
    #   /usr/bin/time -v -o $script_dir/../data/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt fastp -w ${words[2]} -i ${names_array[0]}.fastq -I ${names_array[1]}.fastq -o ${names_array[0]}_trimmed.fastq -O ${names_array[1]}_trimmed.fastq
    #   echo "running kma for ${words[@]}"
    #   /usr/bin/time -v -o $script_dir/../data/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt -a kma -t ${words[3]} -ipe ${names_array[0]}_trimmed.fastq ${names_array[1]}_trimmed.fastq -o ../resfinder_res/test -t_db ../databases/resfinder_db/ResFinder -1t1 -ef -cge -nf
      
    #   for name in "${names_array[@]}"; do
    #     rm "$(pwd)/${name}_trimmed.fastq"
    #   done
    #   echo "5 second sleep"
    #   sleep 5
    # fi

    
    
    # if zipped and pipe
    # if [[ ${words[0]} = "zipped" && ${words[1]} = "pipe" ]]; then
    #   echo "running fastp piped to kma for ${words[@]}"
    #   /usr/bin/time -v -o $script_dir/../data/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt dash -c \
    #    "fastp -w ${words[2]} -i ${names_array[0]}.fastq.gz -I ${names_array[1]}.fastq.gz --stdout \
    #    | kma -int -- -t ${words[3]} -o ../resfinder_res/test -t_db ../databases/resfinder_db/ResFinder -1t1 -ef -cge -nf"
    #   echo "5 second sleep"
    #   sleep 5
    # fi
    
    # if unzipped and pipe
    # if [[ ${words[0]} = "unzipped" && ${words[1]} = "pipe" ]]; then
    #   echo "running fastp piped to kma for ${words[@]}"
    #   /usr/bin/time -v -o $script_dir/../data/${words[0]}_${words[1]}_${words[2]}_${words[3]}.txt dash -c \
    #    "fastp -w ${words[2]} -i ${names_array[0]}.fastq -I ${names_array[1]}.fastq --stdout \
    #    | kma -int -- -t ${words[3]} -o ../resfinder_res/test -t_db ../databases/resfinder_db/ResFinder -1t1 -ef -cge -nf"
    #   echo "5 second sleep"
    #   sleep 5
    # fi



  done
fi

conda deactivate
