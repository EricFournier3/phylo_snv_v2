process PARSE_SNV_TABLE {

  publishDir "${params.current_snv_phyl_parsed_snvtable_dir}", mode: 'copy'
  publishDir "${params.current_partage_basedir_snv_phyl}", mode: 'copy'

  input:
  path(snvtable)
  val(mybasedir_out)
  val(myout_grapetree_base_name)
  val(myref_name)
  val(myout_base_name)

  output:
  path("${myout_grapetree_base_name}-profile.tsv"), emit: grapetree_profile
  path("${myout_base_name}-profile.tsv"), emit: profile
  path("${myout_base_name}-strains.tsv"), emit: strains
  path("${myout_grapetree_base_name}-metadata.tsv"), emit: grapetree_strains

  script:
  
  """
  #echo "IN PARSE_SNV_TABLE"
  parse_snvtable.py  --snv-table "${snvtable}" --ref-name "${myref_name}" --out-base-name "${myout_base_name}" --out-grapetree-base-name "${myout_grapetree_base_name}" --basedir-out "${params.current_snv_phyl_parsed_snvtable_dir}"

  cp ${params.current_snv_phyl_res_dir}/make/snvMatrix.tsv ${params.current_partage_basedir_snv_phyl}
  #BIOIN-1045
  cp ${params.current_snv_phyl_res_dir}/phyml/phylogeneticTree.newick ${params.current_partage_basedir_snv_phyl}
  cp ${params.current_snv_phyl_res_dir}/phyml/phylogeneticTreeStats.txt ${params.current_partage_basedir_snv_phyl}

  """

}

process MAKE_GRAPETREE_NEWICK {
  publishDir "${params.current_snv_phyl_parsed_snvtable_dir}", mode: 'copy'
  publishDir "${params.current_partage_basedir_snv_phyl}", mode: 'copy'

  input:
  path(grapetree_profile)

  output:
  path("grapetree-tree.nwk")

  script:
  """
  #echo "IN MAKE_GRAPETREE_NEWICK"

  grapetree.py -p "${grapetree_profile}" -m MSTreeV2 > grapetree-tree.nwk

  """

}

//BIOIN-1051 on met obsolete
process MAKE_SNV_PHYL_SAMPLESHEET_OBSOLETE {

  input:
  tuple val(sample_name),path(reads)
  path(reject_samples_files) 

  script:

  sample_name_split = sample_name.split('_')
  sample_name_short = sample_name_split[0]

  snvphyl_samplesheet = "${params.current_snv_phyl_samplesheet}"

  """
  #!/usr/bin/env python
  import pandas as pd
  import os

  def check_if_rejected():
      reject_samples_df = pd.read_csv("${reject_samples_files}",index_col = False)
      reject_samples_list = list(reject_samples_df['SAMPLES'])

      if "${sample_name_short}" in reject_samples_list:
          return(True)

      return(False)
mycolumns = ['sample','fastq_1','fastq_2','reference_assembly','metadata_1','metadata_2','metadata_3','metadata_4','metadata_5','metadata_6','metadata_7','metadata_8']
  #print("IN MAKE_SNV_PHYL_SAMPLESHEET")

  mycolumns = ['sample','fastq_1','fastq_2','reference_assembly','metadata_1','metadata_2','metadata_3','metadata_4','metadata_5','metadata_6','metadata_7','metadata_8']

  rejected = check_if_rejected()


  #print("${sample_name_short}", " is ",rejected)

  if rejected:
      exit(0)


  if os.path.exists("${snvphyl_samplesheet}"):
      df = pd.read_csv("${snvphyl_samplesheet}",sep=",",index_col=False)
      new_row = dict(zip(mycolumns,["${sample_name_short}","${params.current_fastp_reads}/${reads[0]}","${params.current_fastp_reads}/${reads[1]}","","","","","","","","",""]))
      df = df.append(new_row,ignore_index=True)
      df.to_csv("${snvphyl_samplesheet}",sep=",",index=False)
  else:
      df = pd.DataFrame([["${sample_name_short}","${params.current_fastp_reads}/${reads[0]}","${params.current_fastp_reads}/${reads[1]}","","","","","","","","",""]],columns=mycolumns)
      df.to_csv("${snvphyl_samplesheet}",sep=",",index=False)

  """

}

//BIOIN-1051
process MAKE_SNV_PHYL_SAMPLESHEET {

  input:
  val mytuple
  path(reject_samples_files)

  script:

  snvphyl_samplesheet = "${params.current_snv_phyl_samplesheet}"

  """
  #!/usr/bin/env python
  import pandas as pd
  import os
  import re

  def check_if_rejected(mysample):
      reject_samples_df = pd.read_csv("${reject_samples_files}",index_col = False)
      reject_samples_list = list(reject_samples_df['SAMPLES'])

      if mysample in reject_samples_list:
          return(True)

      return(False)

  mystring = "${mytuple}"
  mystring = mystring.replace('[','&').replace(',','&').replace(' ','&').replace(']','&')
  myl = mystring.split('&')

  mydict = {}

  mycolumns = ['sample','fastq_1','fastq_2','reference_assembly','metadata_1','metadata_2','metadata_3','metadata_4','metadata_5','metadata_6','metadata_7','metadata_8']

  df = pd.DataFrame(columns=mycolumns)

  for elem in myl:
      if re.search("R1_001_trimmed_1.fastq.gz",elem):
          sample = os.path.basename(elem).split('_')[0]

          rejected = check_if_rejected(sample)

          if rejected:
              continue

          if not sample in mydict:
              new_row = dict(zip(mycolumns,[sample,elem,re.sub(r"R1_001_trimmed_1.fastq.gz","R2_001_trimmed_2.fastq.gz",elem),"","","","","","","","",""]))

              df = df.append(new_row,ignore_index=True)


  df.to_csv("${snvphyl_samplesheet}",sep=",",index=False)


  """

}
