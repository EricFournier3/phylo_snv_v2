#! /usr/bin/env python
import pandas as pd
import os
import argparse

"""
Eric Fournier 2024-08-01
BIOIN-987

Command example
python parse_snvtable.py  --snv-table /data/soft/snv_phyl_nextflow/SNVPhyl_Nextflow_TEST/TEST/RESULTS/snvTable.tsv --ref-name LMICDA --out-base-name mymicda --out-grapetree-base-name  mygrap --basedir-out /data/soft/snv_phyl_nextflow/SNVPhyl_Nextflow_TEST/TEST/RESULTS/
"""




parser = argparse.ArgumentParser(description="Parse snvTable.tsv")

parser.add_argument('--snv-table',help="snvTable.tsv path",required=True)
parser.add_argument('--ref-name',help="reference name",required=True)
parser.add_argument('--out-base-name',help="Output basename",required=True)
parser.add_argument('--basedir-out',help="Output directory",required=True)
parser.add_argument('--out-grapetree-base-name',help="Output basename for grapetree input",required=True)

args = parser.parse_args()

snv_table = args.snv_table
refname = args.ref_name
output_base = args.out_base_name 
output_grapetree_base = args.out_grapetree_base_name

basedir_out = args.basedir_out

out_profile = os.path.join(output_base + "-profile.tsv")
out_strains = os.path.join(output_base + "-strains.tsv")

out_grapetree_profile = os.path.join(output_grapetree_base + "-profile.tsv")
out_grapetree_metadata = os.path.join(output_grapetree_base + "-metadata.tsv")

position_information = []

nucleotide_data = {}

snv_table_df = pd.read_csv(snv_table,sep="\t",index_col=False)

mycolumns = list(snv_table_df.columns)

strains = mycolumns[3:]

if (strains[0] == 'Reference')  and (refname):
    strains[0] = refname

total_pos = 0
good_pos = 0

for index,row in snv_table_df.iterrows():
   
    total_pos += 1
    dna_list = list(row[3:])
    if  row['Status'] != 'valid':
        continue
    elif len(set(dna_list) - set(['A','C','G','T'])) > 0:
        continue
    else:
        good_pos += 1

        for i in range(0,len(dna_list)):
            if i not in nucleotide_data:
                nucleotide_data[i] = dna_list[i]
            else:
                nucleotide_data[i] =  nucleotide_data[i] + "\t"  + dna_list[i]
            pass
        position_information.append(row['#Chromosome'] + '_' + str(row['Position']))

wf_strains = open(out_strains,'w')
wf_strains.write("ST\tStrain\n")

wf_grapetree_metadata = open(out_grapetree_metadata,'w')
wf_grapetree_metadata.write("ID\tST\n")

my_types = {}
curr_unused_type = 1
duplicate_profiles = 0

with open(out_profile,'w') as wf:
    wf.write("ST\t" + "\t".join(position_information) + "\n")
    for curr in range(0,len(strains)):
        strain_id = strains[curr]
        strain_id_cut = strain_id.split('_')[0]
        snp_profile = nucleotide_data[curr]

        if snp_profile not in my_types:
            curr_type = curr_unused_type
            curr_unused_type += 1
            my_types[snp_profile] = [strain_id,curr_type]
            wf.write(str(curr_type) + "\t" + snp_profile + "\n")
        else:
            pass
            previous_strain_id,curr_type = my_types[snp_profile]
            duplicate_profiles += 1

        wf_strains.write(str(curr_type) + "\t" + str(strain_id) + "\n")
        wf_grapetree_metadata.write(str(strain_id_cut) + "\t" + str(curr_type) + "\n")


my_types = {}

with open(out_grapetree_profile,'w') as wf:
    wf.write("#Name\t" + "\t".join(position_information) + "\n")
    for curr in range(0,len(strains)):
        strain_id = strains[curr]
        strain_id_cut = strain_id.split('_')[0]
        snp_profile = nucleotide_data[curr]

        wf.write(strain_id_cut + "\t" + snp_profile + "\n")

wf_strains.close()
wf_grapetree_metadata.close()

