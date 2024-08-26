#! /usr/bin/env python
import json
import os
import argparse

"""
Eric Fournier 2024-08-26
BIOIN-999
"""

#sample name is L00166407001LEGIO_S25
#L00166407001LEGIO_S25.fastp.json
#L00166407001LEGIO_S25_R1_001_trimmed_1.fastq.gz
#L00166407001LEGIO_S25_R2_001_trimmed_2.fastq.gz

parser = argparse.ArgumentParser(description="Filter fastp reads bases on count")

parser.add_argument('--sample-name',help="Sample Name",required=True)

parser.add_argument('--min-reads-count',help="Minimum fastq count reads after clean. Sum of R1 + R2",required=True,type=int)

args = parser.parse_args()

sample_name = args.sample_name
min_reads_count = int(args.min_reads_count)


print("SAMPLE NAME IS ",sample_name)


json_file = open(sample_name + ".fastp.json")
json_load = json.load(json_file)


reads_count = int(json_load["filtering_result"]["passed_filter_reads"])

json_file.close()

if reads_count < min_reads_count:
    print(reads_count, " is less than ", min_reads_count)
    cmd = "rm {0}.fastp.json {0}_*_trimmed_*.fastq.gz".format(sample_name)
    print("CMD IS ",cmd)
