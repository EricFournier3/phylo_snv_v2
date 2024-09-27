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

#print("sample_list_file ",sample_list_file)
#print("sample_index_file ",sample_index_file)

samples_list_df = pd.read_csv(sample_list_file,sep="\t",index_col=False)
sample_index_df = pd.read_csv(sample_index_file,sep="\t",index_col=False)

merge_df = pd.merge(samples_list_df,sample_index_df,how='inner',on='SAMPLE')

#TODO DESACTIVER
'''
d1 = {'SAMPLE':'L00301982001LEGIO','RUN_NAME':'231205_VL00131_163_AAF7K5GM5_OLD'}
d2 = {'SAMPLE':'L00301982001LEGIO','RUN_NAME':'231205_VL00131_163_AAF7K5GM5_1'}
d3 = {'SAMPLE':'L00301982001LEGIO','RUN_NAME':'231205_VL00131_163_AAF7K5GM5_2'}
d4 = {'SAMPLE':'L00301982001LEGIO','RUN_NAME':'231205_VL00131_163_AAF7K5GM5_3'}
merge_df = merge_df.append(d1,ignore_index=True)
merge_df = merge_df.append(d2,ignore_index=True)
merge_df = merge_df.append(d3,ignore_index=True)
merge_df = merge_df.append(d4,ignore_index=True)
'''

merge_df = merge_df.loc[~merge_df['RUN_NAME'].str.contains('_OLD'),:]
merge_df = merge_df.sort_values(by=['SAMPLE','RUN_NAME'],ascending=[True,True])
merge_df = merge_df.drop_duplicates(subset=['SAMPLE'],keep='last')
merge_df = merge_df.rename(columns={'SAMPLE':'SAMPLE_NAME'})

merge_df.to_csv("sample_sheet.tsv",sep="\t",index=False)













