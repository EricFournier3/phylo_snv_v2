#! /usr/bin/env python
import pandas as pd
import os
import argparse

parser = argparse.ArgumentParser(description="Build samples sheet")

parser.add_argument('--sample-list-file',help="user samples list file",required=True)
parser.add_argument('--sample-index-file',help="samples_index.tsv in /data/run_raw_data/",required=True)

args = parser.parse_args()

sample_list_file = args.sample_list_file
sample_index_file = args.sample_index_file

print("sample_list_file ",sample_list_file)
print("sample_index_file ",sample_index_file)

samples_list_df = pd.read_csv(sample_list_file,sep="\t",index_col=False)
sample_index_df = pd.read_csv(sample_index_file,sep="\t",index_col=False)

merge_df = pd.merge(samples_list_df,sample_index_df,how='inner',on='SAMPLE')
merge_df.to_csv("/home/foueri01@inspq.qc.ca/TEMP/20240926/merge_df.tsv",sep="\t",index=False)
