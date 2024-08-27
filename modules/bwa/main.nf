process BWA {
  cpus 10

  module 'bwa/v0.7.17:samtools/samtools-1.17'

  input:
  tuple val(sample_name), path(reads)
  tuple path(fasta),path(amb),path(ann),path(bwt),path(pac),path(sa)

  output:
  tuple val("${sample_name_short}"), path("${sample_name_short}_sorted.bam"), path("${sample_name_short}_sorted.bam.bai"), emit: bam_output

  script:

  sample_name_short = "${sample_name}".split("_")[0]

  """

  #echo "IN BWA"

  cmd_map="bwa mem ${fasta} ${reads[0]} ${reads[1]} -t  ${task.cpus}  > ${sample_name_short}.sam"
  eval "\${cmd_map}"

  cmd_sam_to_bam="samtools view -bS --threads ${task.cpus}  -o ${sample_name_short}.bam ${sample_name_short}.sam"
  eval "\${cmd_sam_to_bam}"

  cmd_sort="samtools sort -m 5G --threads ${task.cpus} -o ${sample_name_short}_sorted.bam ${sample_name_short}.bam"
  eval "\${cmd_sort}"

  cmd_index="samtools index ${sample_name_short}_sorted.bam"
  eval "\${cmd_index}"

  """
  
}


process INDEX_REF {

  module 'bwa/v0.7.17:samtools/samtools-1.17'

  input:
  path(fasta_ref)

  output:
  tuple path("${fasta_ref}"),path("${fasta_ref}.amb"),path("${fasta_ref}.ann"),path("${fasta_ref}.bwt"),path("${fasta_ref}.pac"),path("${fasta_ref}.sa"), emit: reference_fasta

  script:

  """
  #echo "IN INDEX_REF"

  bwa index -p "${fasta_ref}" "${fasta_ref}"   
  """



}
