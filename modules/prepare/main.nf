process MAKE_DIRECTORIES{
  
  input:
  val(species)
  val(out_basedir)
  val(out_dirname)

  output:
  path("make_directory_done.txt"), emit: flag_file

  script:

  """
  echo "IN MAKE_DIRECTORIES"

  if ! [ -d "${params.current_out_dir}" ]
   then
   mkdir "${params.current_out_dir}"
   mkdir "${params.current_fastq_raw}"
   mkdir "${params.current_fastp_reads}"
   mkdir "${params.current_fasta_reads}"
   mkdir "${params.current_snv_phyl_parsed_snvtable_dir}"
   mkdir "${params.current_fastqc_dir}"
  fi

   touch "make_directory_done.txt"
  """

}

process IMPORT_FASTQ{
  input:
  path(sample_sheet)
  path(makedir_flag_file)

  script:

  """
  echo "IN IMPORT_FASTQ"
  import_fastq.py --sample-sheet "${sample_sheet}"  --nextseq-rawdata-basedir "${params.nextseq_rawdata_basedir}"  --fastq-dir  "${params.current_fastq_raw}"
  """

}























