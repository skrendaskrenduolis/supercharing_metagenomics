import subprocess


data_directory = f"../../r_data_analysis/thesis_plots/"
#tsv_name = "gpu_tests.tsv"
with subprocess.Popen(("ls", "-p" , data_directory), stdout=subprocess.PIPE) as ls:
    filenames = subprocess.check_output(("grep", "-v", "/"), stdin=ls.stdout).decode("utf-8").split()
    ls.wait()
    print(filenames)

for name in filenames:
    print("\\begin{figure}[H]")
    print(f"\includegraphics[width=14cm]{{Pictures/plots/{name}}}")
    print("\centering")
    print("\caption{compression}")
    print(f"\label{{fig:{name[:-4]}}}")
    print("\end{figure}")
    print()