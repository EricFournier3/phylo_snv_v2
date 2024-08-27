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

def check_fastp_qc(fastp_json,min_reads_count):
    json_file = open(fastp_json)
    json_load = json.load(json_file)
    reads_count = int(json_load["filtering_result"]["passed_filter_reads"])
    json_file.close()

    if reads_count < int(min_reads_count):
        return False

    return True

parser = argparse.ArgumentParser(description="Filter fastp reads based on count")
parser.add_argument('--unfiltered-list',help="Ksnp3 unfiltered list",required=True)
parser.add_argument('--fastp-dir',help="fastp directory",required=True)
parser.add_argument('--min-reads-count',help="Minimum fastq count reads after clean. Sum of R1 + R2",required=True)
parser.add_argument('--filtered-samples-dir',help="Filtered samples directory",required=True)

args = parser.parse_args()

unfiltered_list_file = args.unfiltered_list
filtered_list_file = re.sub(".txt$","_filtered.txt",os.path.basename(unfiltered_list_file))

rejected_samples_file = "rejected_samples.txt"
rejected_samples_df = pd.DataFrame(columns=["SAMPLES"])

fastp_dir = args.fastp_dir
min_reads_count = args.min_reads_count
filtered_samples_dir = args.filtered_samples_dir 

unfiltered_list_df = pd.read_csv(unfiltered_list_file,sep="\t",index_col=False,header=None) 

with open(filtered_list_file,'w') as wf:

    for index, row in unfiltered_list_df.loc[:,].iterrows():
        fasta_path = row[0]
        sample = row[1]
        fastp_json = glob.glob(fastp_dir + "/" + sample + "_*.fastp.json")[0]

        qc_pass = check_fastp_qc(fastp_json,min_reads_count)
        
        if qc_pass:
            wf.write(fasta_path + "\t" + sample + "\n")
        else:
            rejected_samples_df = rejected_samples_df.append({'SAMPLES':sample},ignore_index=True)
    
rejected_samples_df.to_csv(rejected_samples_file,sep="\t",index=False)

