process SAMTOOLS_STATS {

  cpus 10

  module 'samtools/samtools-1.17'

  input:
  tuple val(sample_name), path(bam), path(bam_index)
  tuple path(fasta_ref),path(amb),path(ann),path(bwt),path(pac),path(sa)
  

  script:

  """
  echo "IN SAMTOOLS"

  samtools flagstat --threads "${task.cpus}" "${bam}" > "${sample_name}".flagstat
  samtools idxstats  "${bam}" > "${sample_name}".idxstats
  samtools stats --threads "${task.cpus}" --ref-seq  "${fasta_ref}" "${bam}" > "${sample_name}".stats

  """


}
