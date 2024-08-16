process MULTIQC {

  publishDir params.current_partage_basedir, mode: 'copy'

  input:
  path(qc_files)


  output:
  path('multiqc_data',type: 'dir')

  script:
  
  """
  
  echo "IN MULTIQC"

  multiqc ${qc_files} -o multiqc_data

  """


}

