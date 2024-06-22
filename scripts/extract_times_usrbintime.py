import subprocess
import glob

data_directory = f"../data/experiment_raw/gpu_times/"
tsv_name = "gpu_tests.tsv"
with subprocess.Popen(("ls", "-p" , data_directory), stdout=subprocess.PIPE) as ls:
    filenames = subprocess.check_output(("grep", "-v", "/"), stdin=ls.stdout).decode("utf-8").split()
    ls.wait()
    print(filenames)


for filename in filenames:
    if "txt" in filename:
        with open(f"{filename}.elapsed", "wb") as outfile:
            #full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
            time_file_text = subprocess.Popen(("cat", f"{data_directory}{filename}"), stdout=subprocess.PIPE)
            elapsed_time = subprocess.Popen(("grep", "Elapsed"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
            times = subprocess.check_output(("gawk", f'''{{ print "{filename}\t"$8 }}'''), stdin=elapsed_time.stdout)
            outfile.write(times)

# for filename in filenames:
#     if "nvidiasmi" in filename:
#         continue
#     with open(f"{filename}.elapsed", "wb") as outfile:
#         #full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
#         time_file_text = subprocess.Popen(("cat", f"{data_directory}{filename}"), stdout=subprocess.PIPE)
#         elapsed_time = subprocess.Popen(("grep", "Elapsed"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
#         times = subprocess.check_output(("gawk", f'''{{ print "{filename}\t"$8 }}'''), stdin=elapsed_time.stdout)
#         outfile.write(times)

    # with open(f"{filename}.user", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "user"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times)

    # with open(f"{filename}.sys", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "sys"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times)

    # with open(f"{filename}.cycles", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "cycles"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times) 

    # with open(f"{filename}.instructions", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "instructions"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times) 

    # with open(f"{filename}.ipc", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "instructions"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $4 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times)

    # with open(f"{filename}.cr", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "cache-references"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
    #     outfile.write(times)

    # with open(f"{filename}.cm", "wb") as outfile:
    #     full_file_dir = f"../data/pipetest/{subfolder}/{filename}"
    #     time_file_text = subprocess.Popen(("cat", full_file_dir), stdout=subprocess.PIPE)
    #     elapsed_time = subprocess.Popen(("grep", "cache-misses"), stdin=time_file_text.stdout, stdout=subprocess.PIPE)
    #     times = subprocess.check_output(("gawk", f'''{{ print $1 }}'''), stdin=elapsed_time.stdout)
        # outfile.write(times)

    with open(f"{filename}.pasted", "wb") as pasted:
        _ = subprocess.run(["paste", f"{filename}.elapsed"], stdout=pasted)
        _ = subprocess.call(["rm", f"{filename}.elapsed"])

    
with open(f"header.txt", "wb") as header_file:
    header_file.write(b"name\telapsed_time\n")

with open(f"{data_directory}/{tsv_name}", "wb") as final:
    pasted_files = glob.glob("*.pasted")
    cat_command = ["cat", "header.txt"] + pasted_files
    rm_command = ["rm"] + pasted_files
    print(cat_command)
    print(rm_command)
    _ = subprocess.run(cat_command, stdout=final)
    _ = subprocess.call(rm_command)
            