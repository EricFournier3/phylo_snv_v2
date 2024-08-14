process FASTQ_TO_FASTA {

  publishDir "${params.current_fasta_reads}", mode: 'symlink'
  module 'seqtk/1.3.106'

  input:
  tuple val(sample_name_prefix), path(fastpseq)

  output:
  path("${sample_name}.fasta"), emit: fasta_out

  script:

  sample_name = sample_name_prefix.split('_')[0]

  """
  echo "IN FASTQ_TO_FASTA"

  cmd_1="seqtk seq -a  ${fastpseq[0]} > ${sample_name}_R1.fasta"
  cmd_2="seqtk seq -a  ${fastpseq[1]} > ${sample_name}_R2.fasta"

  eval "\${cmd_1}"
  eval "\${cmd_2}"

  cat_cmd="cat ${sample_name}_R1.fasta ${sample_name}_R2.fasta > ${sample_name}.fasta"
  eval "\${cat_cmd}"

  """

}

process BUILD_READS_FASTA_LIST {

  input:
  val(reads_fasta_list)

  output:
  val("${params.current_ksnp3_samples_list}"), emit: ksnp3_samples_list

  script:

  myFile = file("${params.current_ksnp3_samples_list}")

  for (myfasta : reads_fasta_list){
    mylist =  myfasta.toString().split('/')
    fasta_name = mylist[mylist.size() - 1]
    sample_name = fasta_name.split("\\.")[0]
    myFile.append("${myfasta}\t${sample_name}\n")
  }
  
  """
  echo "IN BUILD_READS_FASTA_LIST"
  """


}

process MAKE_SNV_PHYL_SAMPLESHEET {

  input:
  tuple val(sample_name),path(reads)

  script:

  sample_name_split = sample_name.split('_')
  sample_name_short = sample_name_split[0]

  snvphyl_samplesheet = "${params.current_snv_phyl_samplesheet}"

  """
  #!/usr/bin/env python
  import pandas as pd
  import os

  print("IN MAKE_SNV_PHYL_SAMPLESHEET")

  mycolumns = ['sample','fastq_1','fastq_2','reference_assembly','metadata_1','metadata_2','metadata_3','metadata_4','metadata_5','metadata_6','metadata_7','metadata_8']

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












