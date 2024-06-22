import subprocess
import sys
import os
import re
import time
from argparse import ArgumentParser
#from joblib import Parallel, delayed

start_time = time.time()

"""Take arguments"""
parser = ArgumentParser(description="File_splitter_and_reverse_complement_caller")
parser.add_argument("-i", action="store", \
                    dest="given_input_file",\
                    type=str, \
                    default=None, \
                    help="Input file path")
parser.add_argument("-j", action="store", \
                    dest="jobs_nr",\
                    type=int, \
                    default=1, \
                    help="Provide number of jobs to run in parallel (default 1)")
parser.add_argument("-d", action="store", \
                    dest="starting_dir",\
                    type=str, \
                    default=os.getcwd(), \
                    help="Provide starting dir (default os.getcwd)")
args = parser.parse_args()
given_input_file = args.given_input_file
jobs_nr = args.jobs_nr
starting_dir = args.starting_dir
os.chdir(starting_dir)


# def unix_call(command):
#     """for testing without qsub"""
#     job = subprocess.run(command.split()) 


def edit_write_content(header_with_sequence, output_file):
    """
    Take string that has the header and the sequence
    split them, and write them
    """
    header, sequence = header_with_sequence.split(b"\n", maxsplit = 1)
    header = header + b"\n"
    output_file.write(header)
    output_file.write(sequence)


def open_subfile_run_qsub(outfile_name, header_and_sequence):
    """
    Open the subfile, write the header and sequence into the subfile
    and submit the command to qsub
    return the job ID
    """
    with open(outfile_name, "wb") as output_file:
        edit_write_content(header_and_sequence, output_file)
        #print(f"python3 fasta_reverser -i {outfile_name}", file=sys.stderr)        
        submitted_command = f"python3 {starting_dir}/reverse_complementer.py -i {starting_dir}/{outfile_name}"
        return submitted_command

def syscall(command):
    """"""
    subprocess.run(command.split(), check = False)


def int_extractor(input_str):
    '''Find file number in the name'''
    file_number_search = re.search(r"rc_sequence_(\d+)\.fsa", input_str)
    file_number = int(file_number_search.group(1))
    return file_number

#if folders dont exist, create them
if not os.path.exists(f"{starting_dir}/subfiles"):
    make_subfile_dir = subprocess.run(["mkdir", f"{starting_dir}/subfiles"], check=False)
# if not os.path.exists(f"{starting_dir}/rev_comp_subfiles"):
#     make_rev_comp_subfile_dir = subprocess.run(["mkdir", f"{starting_dir}/rev_comp_subfiles"], check=False)



if __name__ == "__main__":
    try:
        command_list = []
        with open(given_input_file, "rb") as input_file:

            #initialize variables
            #contains chunks
            chunk_list = []

            #counts headers
            HEADER_COUNTER = 0

            #keeps track of file number
            OUTFILE_NUMBER = 0

            #size of chunk
            CHUNKSIZE = 16777216

            #set containing submitted job IDs
            submitted_job_set = set()
            
            #iterate over input file
            while True:
                #add chunks to list and count headers in chunks
                chunk = input_file.read(CHUNKSIZE)
                HEADER_COUNTER += chunk.count(b">")
                chunk_list.append(chunk)

                
                while HEADER_COUNTER >= 2:
                    OUTFILE_NUMBER += 1

                    #join chunks into byte string and clear list
                    MAIN_BYTE_STRING = b"".join(chunk_list)
                    chunk_list = []
                    
                    #split at two > symbols, leaving only the first
                    #header, its sequence, and the remaining byte string
                    main_byte_list = MAIN_BYTE_STRING.split(b">", maxsplit = 2)

                    #combine header and sequence
                    header_and_sequence = b">".join(main_byte_list[:2])

                    #spliting removes >, so add it back
                    MAIN_BYTE_STRING = b">" + b">".join(main_byte_list[2:])
                    
                    #count headers again for the loop
                    HEADER_COUNTER = MAIN_BYTE_STRING.count(b">")
                    
                    #add the remaining byte string to the chunk list and clear the byte string variable
                    chunk_list.append(MAIN_BYTE_STRING)
                    MAIN_BYTE_STRING = b""

                    #create the file name with current number, write the subfile and submit job
                    outfile_name = f"subfiles/sequence_{OUTFILE_NUMBER}.fsa"
                    submitted_job = open_subfile_run_qsub(outfile_name, header_and_sequence)
                    #command_list.append(submitted_job)

                if len(chunk) < CHUNKSIZE:
                    #same process as above loop but final iteration will use the
                    #remainder byte string
                    MAIN_BYTE_STRING = b"".join(chunk_list)
                    chunk_list = []
                    OUTFILE_NUMBER += 1
                    outfile_name = f"subfiles/sequence_{OUTFILE_NUMBER}.fsa"
                    submitted_job = open_subfile_run_qsub(outfile_name, MAIN_BYTE_STRING)
                    #command_list.append(submitted_job)
                    break
        
    #     print(f"File reads done: {time.time() - start_time} s")
    #     #run the parallel jobs by 
    #     result = Parallel(n_jobs=jobs_nr)(delayed(syscall)(x) for x in command_list)

    #     print(f"Parallel processes done: {time.time() - start_time} s")
    #     #change working directory to where reverse complement files should be stored
    #     os.chdir(f"{starting_dir}/rev_comp_subfiles")

    #     #get the file names in the folder and sort them in list by number
    #     list_files_cmd = subprocess.run(["ls"], stdout=subprocess.PIPE, universal_newlines=True, check=False)
    #     file_names = list_files_cmd.stdout.strip().split("\n")
    #     file_names.sort(key=int_extractor)

        
    #     # collect files and concatenate them to result
    #     if os.path.exists(f"{starting_dir}/revcomp_human.fsa"):
    #         subprocess.run(["rm", f"{starting_dir}/revcomp_human.fsa"], check = True)
        
    #     subprocess.run(["cat"] + file_names, stdout=open(f"{starting_dir}/revcomp_human.fsa", "w"), check = False)
    #     print(f"Subfile concat done: {time.time() - start_time} s")
    #     os.chdir(starting_dir)
    #     subprocess.run(["rm", "-r", "rev_comp_subfiles", "subfiles"], check = False)
    #     print(f"Subfile removal done: {time.time() - start_time} s")
    except FileNotFoundError as error:
        print(error)
        sys.exit(1)

