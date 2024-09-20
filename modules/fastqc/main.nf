process FASTQC {

  publishDir "${params.current_fastqc_dir}", mode: 'copy'

  module 'fastqc/v0.12.1'

  input:
  tuple val(sample_name_prefix), path(rawseq),path(fastpseq)

  output:
  path '*fastqc*', emit: fastqc_out

  script:

  sample_name = sample_name_prefix.split('_')[0]

  """
  #echo "IN FASTQC"

  fastqc -q --threads ${task.cpus} ${rawseq[0]} ${rawseq[1]}
  fastqc -q --threads ${task.cpus} ${fastpseq[0]} ${fastpseq[1]}

  """


}
