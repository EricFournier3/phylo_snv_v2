#! /usr/bin/env python
import json
import os
import argparse
import pandas as pd
import json
import glob
import re


"""
Eric Fournier 2024-08-26
BIOIN-999
"""

#TODO LOG POUR SAMPLE FILTRE


def check_fastp_qc(fastp_json,min_reads_count):
    json_file = open(fastp_json)
    json_load = json.load(json_file)
    reads_count = int(json_load["filtering_result"]["passed_filter_reads"])
    json_file.close()

    if reads_count < int(min_reads_count):
        return False

    return True

#sample name is L00166407001LEGIO_S25
#L00166407001LEGIO_S25.fastp.json
#L00166407001LEGIO_S25_R1_001_trimmed_1.fastq.gz
#L00166407001LEGIO_S25_R2_001_trimmed_2.fastq.gz

parser = argparse.ArgumentParser(description="Filter fastp reads based on count")
parser.add_argument('--unfiltered-list',help="Ksnp3 unfiltered list",required=True)
parser.add_argument('--fastp-dir',help="fastp directory",required=True)
parser.add_argument('--min-reads-count',help="Minimum fastq count reads after clean. Sum of R1 + R2",required=True)
parser.add_argument('--filtered-samples-dir',help="Filtered samples directory",required=True)

args = parser.parse_args()

unfiltered_list_file = args.unfiltered_list
filtered_list_file = re.sub(".txt$","_filtered.txt",os.path.basename(unfiltered_list_file))
print(filtered_list_file)

rejected_samples_file = "rejected_samples.txt"
rejected_samples_file_handle = open(rejected_samples_file,'w')

fastp_dir = args.fastp_dir
min_reads_count = args.min_reads_count
filtered_samples_dir = args.filtered_samples_dir 

print("UNFILTERED ",unfiltered_list_file)
print("FASTP_DIR ", fastp_dir)
print("min_reads_count ", min_reads_count)

with open(unfiltered_list_file) as rf:
    for line in rf:
        print("LINE ",line) 

unfiltered_list_df = pd.read_csv(unfiltered_list_file,sep="\t",index_col=False,header=None) 
#print(unfiltered_list_df)

with open(filtered_list_file,'w') as wf:

    for index, row in unfiltered_list_df.loc[:,].iterrows():
        fasta_path = row[0]
        print(fasta_path)
        sample = row[1]
        fastp_json = glob.glob(fastp_dir + "/" + sample + "_*.fastp.json")[0]
        print("JSON ",fastp_json)

        qc_pass = check_fastp_qc(fastp_json,min_reads_count)
        
        if qc_pass:
            wf.write(fasta_path + "\t" + sample + "\n")
        else:
            print(sample, " FAILED")
    

rejected_samples_file_handle.close()

