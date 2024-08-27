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
  #echo "IN FASTQ_TO_FASTA"

  cmd_1="seqtk seq -a  ${fastpseq[0]} > ${sample_name}_R1.fasta"
  cmd_2="seqtk seq -a  ${fastpseq[1]} > ${sample_name}_R2.fasta"

  eval "\${cmd_1}"
  eval "\${cmd_2}"

  cat_cmd="cat ${sample_name}_R1.fasta ${sample_name}_R2.fasta > ${sample_name}.fasta"
  eval "\${cat_cmd}"

  """

}

process BUILD_READS_FASTA_LIST {

  publishDir "${myFile_basedir}", mode: 'copy', pattern: "*_filtered.txt"
  publishDir "${params.current_filtred_samples_dir}", mode: 'copy', pattern: "rejected_samples.txt"

  input:
  val(reads_fasta_list)

  output:
  path "*_filtered.txt" , emit: ksnp3_samples_list
  path "rejected_samples.txt" , emit: rejected_samples_file

  script:

  myFile = file("${params.current_ksnp3_samples_list}")
  myFile_basedir = myFile.getParent()

  //println "BASEDIR ${myFile_basedir}"
  //println "WORKDIR ${workflow.workDir}"
  //println "CURRENT WORKDIR ${PWD}"
  //println "${task.baseDir}"
  //println "${workDir}"

  for (myfasta : reads_fasta_list){
    mylist =  myfasta.toString().split('/')
    fasta_name = mylist[mylist.size() - 1]
    sample_name = fasta_name.split("\\.")[0]
    myFile.append("${myfasta}\t${sample_name}\n")
  }
  
  """
  #echo "CURRENT WORKDIR BASH \${PWD}"
  build_reads_fasta_list.py --unfiltered-list ${params.current_ksnp3_samples_list} --fastp-dir ${params.current_fastp_reads} --min-reads-count ${params.min_fastp_reads} --filtered-samples-dir  ${params.current_filtred_samples_dir}
  """

}


process BUILD_READS_FASTA_LIST_OBSOLETE {

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
  #echo "IN BUILD_READS_FASTA_LIST"
  """


}




