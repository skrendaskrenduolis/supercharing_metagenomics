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
    file_name = f'{directory}/{script_file_id}_record_temp.pbs.sh'
    #file_name = f'{script_file_id}_temp.pbs.sh'
    with open(file_name, 'w') as outfile:
        outfile.write(script)
    return script

    job = subprocess.run(['bsub', '<', f'{file_name}'], stdout=subprocess.PIPE, universal_newlines=True, check=True) 
    jobid = job.stdout.split('.')[0]
    return jobid







if __name__ == "__main__":
    id_list = ["1.8GB", "9.5GB", "19GB"]
    ram_list = [12, 40, 100]
    minutes_list = [10, 30, 60]
    
    data_directory = "~/main_folder/data/raw"
    time_output_directory = "~/main_folder/data/experiment"
    for file_id, ram_amount, minutes in zip(id_list, ram_list, minutes_list):
        # initiate conda environment
        program_command = "source ~/miniconda3/bin/activate" + "\n"
        program_command += "conda activate ~/miniconda3/envs/metagenomics" + "\n"

        # decompress file to memory
        program_command += f"gunzip -c {data_directory}/{file_id}.fastq.gz > /dev/shm/{file_id}.fastq" + "\n"

        # record file size
        program_command += f"touch {time_output_directory}/fastp_record_{file_id}.txt" + "\n"
        # time fastp when decompressed file is trimmed into /dev/null
        #program_command += f"for i in {{1..50}}; do /usr/bin/time -v -o {time_output_directory}/fastp_runtime_{file_id}.txt -a fastp -w 1 -i /dev/shm/{file_id}.fastq -o /dev/null; sleep 30 done" + "\n"
        program_command += f"perf record -e cpu-clock,faults,cycles,instructions,cache-references,cache-misses -o {time_output_directory}/fastp_record_{file_id}.txt fastp -w 1 -i /dev/shm/{file_id}.fastq -o /dev/null" + "\n"
        # deactivate conda env

        program_command += f"rm \"/dev/shm/{file_id}.fastq\"" + "\n"
        program_command += "conda deactivate"
        
        # submit job
        jobid = bsub_submit(cores=1, hosts=1, ram=ram_amount, exceed_mem=ram_amount,
                            runtime=minutes, \
                            command=program_command, \
                            queue="hpc", name=f"fastp_runtime_{file_id}", \
                            output=f"{time_output_directory}/err_and_out/fastp_runtime_{file_id}.out", \
                            error=f"{time_output_directory}/err_and_out/fastp_runtime_{file_id}.err", \
                            cpu_model="XeonGold6342", script_file_id=file_id)
        print(jobid)
