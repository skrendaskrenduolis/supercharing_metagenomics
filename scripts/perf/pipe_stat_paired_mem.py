import sys
import subprocess
import os

def bsub_submit(command='', directory='', modules='', runtime=60, cores=1, hosts=1, ram=1, queue='hpc', name='',
    output='/dev/null', error='/dev/null', cpu_model='', exceed_mem=1, script_file_id=''):
    """
    Function to submit a job to the Queueing System - without jobscript file
    Parameters are:
    command:   The command/program you want executed together with any parameters.
               Must use full path unless the directory is given and program is there. 
    directory: Working directory - where should your program run, place of your data.
               If not specified, uses current directory.
    modules:   String of space separated modules needed for the run.
    runtime:   Time in minutes set aside for execution of the job.
    cores:     How many cores are used for the job.
    ram:       How much memory in GB is used for the job.
    group:     Accounting - which group pays for the compute.
    output:    Output file of your job.
    error:     Error file of your job.
    """
    runtime = int(runtime)
    cores = int(cores)
    hosts = int(hosts)
    ram = int(ram)
    if cores > 10:
        print("Can't use more than 10 cores on a node")
        sys.exit(1)
    if ram > 120:
        print("Can't use more than 120 GB on a node")
        sys.exit(1)
    if runtime < 1:
        print("Must allocate at least 1 minute runtime")
        sys.exit(1)
    minutes = runtime % 60
    hours = int(runtime/60)
    if hours < 10:
        walltime = "0{:d}:{:02d}".format(hours, minutes)
    else:
        walltime = "{:d}:{:02d}".format(hours, minutes)
    if directory == '':
        directory = os.getcwd()
    # Making a jobscript
    script = '#!/bin/sh\n'
    script += '#BSUB -q ' + queue + '\n'
    script += '#BSUB -J ' + name + '\n'
    script += '#BSUB -n ' + str(cores) + '\n'
    script += '#BSUB -R ' + f'"span[hosts={str(hosts)}]"' + '\n'
    script += '#BSUB -R ' + f'"rusage[mem={str(ram)}GB]"' + '\n'
    script += '#BSUB -M ' + f'{str(exceed_mem)}GB' + '\n'
    script += '#BSUB -W ' + walltime + '\n'
    script += '#BSUB -eo ' + error + '\n'
    script += '#BSUB -oo ' + output + '\n'
    script += '#BSUB -R ' + f'"select[model == {cpu_model}]"' + '\n'

    if modules != '':
        script += 'module load ' + modules + '\n'
    script += command + '\n'
    # The submit
    # return script
    file_name = f'{directory}/{script_file_id}_pipe_stat_mem_temp.pbs.sh'
    #file_name = f'{script_file_id}_temp.pbs.sh'
    with open(file_name, 'w') as outfile:
        outfile.write(script)

    job = subprocess.Popen(['bsub'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=open(f'{file_name}', 'r')) 
    return job







if __name__ == "__main__":
    id_list = ["1GB", "5GB"]
    ram_list = [5, 20]
    minutes_list = [120, 600]

    data_directory = "~/main_folder/data/raw"
    time_output_directory = "~/main_folder/data/experiment"
    for file_id, ram_amount, minutes in zip(id_list, ram_list, minutes_list):
        program_command = "source ~/miniconda3/bin/activate" + "\n"
        program_command += "conda activate ~/miniconda3/envs/metagenomics" + "\n"

        # create time storing files and output dir where necessary
        program_command += f"touch {time_output_directory}/fastp_pipe_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/kma_pipe_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/samtools_sort_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/bcftools_mpileup_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/bcftools_call_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/bcftools_norm_stat_mem_{file_id}.txt" + "\n"
        program_command += f"touch {time_output_directory}/bcftools_filter_stat_mem_{file_id}.txt" + "\n"
        program_command += f"cp -t /dev/shm/ ~/main_folder/data/raw/{file_id}_1.fastq.gz ~/main_folder/data/raw/{file_id}_2.fastq.gz" + "\n"



        program_command += f"for i in {{1..20}}; do mkdir /dev/shm/kma_output_mem ; " 
        program_command += f"perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/fastp_pipe_stat_mem_{file_id}.txt --append fastp -w 1 -i /dev/shm/{file_id}_1.fastq.gz -I /dev/shm/{file_id}_2.fastq.gz --stdout "
        program_command += f"| perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/kma_pipe_stat_mem_{file_id}.txt --append kma -t 1 -int -- -o /dev/shm/kma_output_mem/output_{file_id} -t_db ~/main_folder/databases/resfinder_db/ResFinder -1t1 -ef -cge -nf -sam 4 "
        program_command += f"| samtools view -u - | perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/samtools_sort_stat_mem_{file_id}.txt --append samtools sort -@ 1 -u -o - - "
        program_command += f"| bash -c 'tee >(samtools view -bS - > /dev/shm/output_sorted_mem_{file_id}.bam)' "
        program_command += f"| perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/bcftools_mpileup_stat_mem_{file_id}.txt --append bcftools mpileup - --threads 1  -A -Ou -f ~/main_folder/databases/resfinder_db/all.fsa "
        program_command += f"| perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/bcftools_call_stat_mem_{file_id}.txt --append bcftools call - --ploidy 1 --threads 1 -mv -Ou "
        program_command += f"| perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/bcftools_norm_stat_mem_{file_id}.txt --append bcftools norm - -f ~/main_folder/databases/resfinder_db/all.fsa -Ou "
        program_command += f"| perf stat -e cycles,instructions,cache-references,cache-misses -o {time_output_directory}/bcftools_filter_stat_mem_{file_id}.txt --append bcftools view - -i 'QUAL>=20' -Oz -o /dev/shm/output_mem_{file_id}.vcf.gz ; "

        # remove treimmed file from memory
        program_command += f"rm -r \"/dev/shm/kma_output_mem\" ; "
        program_command += f"rm \"/dev/shm/output_sorted_mem_{file_id}.bam\" ; "
        program_command += f"rm \"/dev/shm/output_mem_{file_id}.vcf.gz\" ;"
        program_command += f"rm \"/dev/shm/{file_id}_1.fastq.gz /dev/shm/{file_id}_2.fastq.gz\" ; done" + "\n"

        # deactivate conda env
        program_command += "conda deactivate"

        
        # submit job
        jobid = bsub_submit(cores=1, hosts=1, ram=ram_amount, exceed_mem=ram_amount,
                            runtime=minutes, \
                            command=program_command, \
                            queue="hpc", name=f"pipe_stat_mem_mem_{file_id}", \
                            output=f"{time_output_directory}/err_and_out/pipe_stat_mem_{file_id}.out", \
                            error=f"{time_output_directory}/err_and_out/pipe_stat_mem_{file_id}.err", \
                            cpu_model="XeonGold6226R", script_file_id=file_id)
        print(jobid)
