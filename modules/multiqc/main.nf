process MULTIQC {

  input:
  path(qc_files)


  script:
  
  """
  
  echo "IN MULTIQC"

  multiqc ${qc_files} -o multiqc_data

  """


}

