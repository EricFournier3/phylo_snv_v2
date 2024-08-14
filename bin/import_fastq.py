#! /usr/bin/env python
import pandas as pd
import os
import argparse

parser = argparse.ArgumentParser(description="Import fastq")

parser.add_argument('--sample-sheet',help="sample sheet path",required=True)
parser.add_argument('--nextseq-rawdata-basedir',help="/data/run_raw_data",required=True)
parser.add_argument('--fastq-dir',help="path to fastq directory",required=True)

args = parser.parse_args()

sample_sheet = args.sample_sheet
nextseq_rawdata_basedir = args.nextseq_rawdata_basedir
fastq_dir = args.fastq_dir


sample_sheet_df = pd.read_csv(sample_sheet,sep="\t",index_col=False)

for index, row in sample_sheet_df.loc[:,].iterrows():
    sample = str(row['SAMPLE_NAME']) 
    run_name = str(row['RUN'])

    year = "20" + str(run_name[0:2])
    run_path = os.path.join(nextseq_rawdata_basedir,year,run_name)

    cp_cmd = "cp {0}/{1}_S*.fastq.gz {2}".format(run_path,sample,fastq_dir)
    os.system(cp_cmd)
