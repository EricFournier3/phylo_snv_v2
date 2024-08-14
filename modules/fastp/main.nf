
process FASTP {

  publishDir "${params.current_fastp_reads}", mode: 'copy',   pattern: "${sample_name_short}*_R*_001_trimmed_*.fastq.gz"
  publishDir "${params.current_fastp_reads}", mode: 'copy', pattern: "${sample_name_short}*.fastp.json"

  module 'fastp/0.23.2'

  input:
  tuple val(sample_name),path(reads)

  output:
  tuple val(sample_name) , path("${sample_name_short}*_R*_001_trimmed_*.fastq.gz"), emit: fastq_paired
  path "${sample_name_short}*.fastp.json" , emit: fastp_json
  val(sample_name), emit: fastq_prefix
  
  script:

  sample_name_split = sample_name.split('_')
  sample_name_short = sample_name_split[0]

  """
  echo "IN FASTP"

  fastp -i ${reads[0]} -I ${reads[1]} -o "${sample_name}_R1_001_trimmed_1.fastq.gz" -O "${sample_name}_R2_001_trimmed_2.fastq.gz"  -l 70 -x --cut_tail --cut_tail_mean_quality 20 --detect_adapter_for_pe --thread 2 --json "${sample_name}.fastp.json"
  """

}
