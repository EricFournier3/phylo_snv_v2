#! /usr/bin/env python

import pandas as pd
from Bio import AlignIO
import os
import glob
import re
import argparse

parser = argparse.ArgumentParser(description="Build ksnp3 distance matrix")

parser.add_argument('--ksnp3-alignment',help="kSNP3 fasta alignment",required=True)

args = parser.parse_args()

ksnp3_alignment = args.ksnp3_alignment

def compute_diff(seq_1,seq_2):
    nb_diff = 0
    nb_compared_sites = 0

    for i in range(0,len(seq_1)):
        if (seq_1[i] != '-') and (seq_2[i] != '-'):
            if seq_1[i] != seq_2[i]:
                nb_diff += 1
            nb_compared_sites += 1

    return(str(nb_diff) + " on " + str(nb_compared_sites))

def build_dataframe(diff_dict,all_rec_id):
    df = pd.DataFrame(index=all_rec_id,columns=all_rec_id)

    for pair,diff in diff_dict.items():
        df.loc[pair[0]][pair[1]] = diff
        df.loc[pair[1]][pair[0]] = diff

    for myid in all_rec_id:
        df.loc[myid][myid] = 0

    return(df)

aln = AlignIO.read(open(ksnp3_alignment), 'fasta')
aln_length = aln.get_alignment_length()

seq_dict = {}
diff_dict = {}

for rec in aln:
    seq_dict[rec.id] = str(rec.seq)

all_rec_id = list(seq_dict.keys())

all_pairs = res = [(a, b) for idx, a in enumerate(all_rec_id) for b in all_rec_id[idx + 1:]]

for mypair in all_pairs:
    nb_diff = compute_diff(seq_dict[mypair[0]],seq_dict[mypair[1]])
    diff_dict[mypair] = nb_diff

distance_matrix_df = build_dataframe(diff_dict,all_rec_id)

out_matrix = "ksnp3_matrix_{}.csv".format(str(aln_length) + "_sites")
distance_matrix_df.to_csv(out_matrix,sep=";",index=True)








