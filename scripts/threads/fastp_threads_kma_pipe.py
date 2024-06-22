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
    if cores > 32:
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
    file_name = f'{directory}/{name}_temp.pbs.sh'
    #file_name = f'{script_file_id}_temp.pbs.sh'

    #return script
    with open(file_name, 'w') as outfile:
        outfile.write(script)
    #return script

    job = subprocess.Popen(['bsub'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=open(f'{file_name}', 'r')) 
    return job







if __name__ == "__main__":
    id_list = ["1GB", "5GB"]
    ram_list = [5, 10]
    minutes_list = [50, 300]
    fastp_thread_list = [1, 2, 4, 8, 16]
    given_core_list = [4, 5, 7,11, 17]

    data_directory = "~/main_folder/data/raw"
    time_output_directory = "~/main_folder/data/experiment"
    for file_id, ram_amount, minutes in zip(id_list, ram_list, minutes_list):
        for fastp_threads, given_cores in zip(fastp_thread_list, given_core_list):
            #loading modules and conda source
            program_command = "module load gcc/13.1.0-binutils-2.40" + "\n"
            program_command += "source ~/miniconda3/bin/activate" + "\n"

            # clearing kma folders and installations if present in script folder and compiling kma on node with flags

            program_command += "bash kma_setup.sh" + "\n"

            # create time storing files and output dir where necessary
            program_command += "conda activate ~/miniconda3/envs/metagenomics" + "\n"
            
            program_command += f"touch {time_output_directory}/fastp_pipe_{fastp_threads}_threads_{file_id}.txt" + "\n"
            
            program_command += f"touch {time_output_directory}/kma_pipe_{fastp_threads}_fastp_threads_{file_id}.txt" + "\n"



            program_command += "for i in {1..10}; do "
            program_command += f"mkdir /dev/shm/kma_output ; " 
            program_command += f"/usr/bin/time -v -o {time_output_directory}/fastp_pipe_{fastp_threads}_threads_{file_id}.txt -a fastp -w {fastp_threads} -i ~/main_folder/data/raw/{file_id}_1.fastq.gz -I ~/main_folder/data/raw/{file_id}_2.fastq.gz --stdout "
            program_command += f"| taskset --cpu-list 0 /usr/bin/time -v -o {time_output_directory}/kma_pipe_{fastp_threads}_fastp_threads_{file_id}.txt -a kma -t 1 -int -- -o /dev/shm/kma_output/output_{file_id} -t_db ~/main_folder/databases/resfinder_db/ResFinder -1t1 -ef -cge -nf -sam 4 > /dev/shm/output.sam ; "


            # remove trimmed file from memory
            program_command += f"rm -r \"/dev/shm/kma_output\" ; "
            program_command += f"rm \"/dev/shm/output.sam\" ; done" + "\n" 
            # deactivate conda env
            program_command += "conda deactivate"

            
            # submit job
            jobid = bsub_submit(cores=given_cores, hosts=1, ram=ram_amount, exceed_mem=ram_amount,
                                runtime=minutes, \
                                command=program_command, \
                                queue="hpc", name=f"fastp_{fastp_threads}_kma_pipe_time_{file_id}", \
                                output=f"{time_output_directory}/err_and_out/fastp_{fastp_threads}_kma_pipe_time_{file_id}.out", \
                                error=f"{time_output_directory}/err_and_out/fastp_{fastp_threads}_kma_pipe_time_{file_id}.err", \
                                cpu_model="XeonGold6226R", script_file_id=file_id)
            print(jobid)