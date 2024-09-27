process MAKE_DIRECTORIES{
  
  input:
  val(species)
  val(out_basedir)
  val(out_dirname)

  output:
  path("make_directory_done.txt"), emit: flag_file

  script:

  """
  #echo "IN MAKE_DIRECTORIES"

  species_dir="${params.out_basedir}/${params.species}"
  species_partage_dir="${params.partage_basedir}"

  if ! [ -d \${species_dir} ]
    then
    mkdir \${species_dir}
  fi

  if ! [ -d \${species_partage_dir} ]
    then
    mkdir \${species_partage_dir}
  fi

  if ! [ -d "${params.current_out_dir}" ]
   then
   mkdir "${params.current_out_dir}"
   mkdir "${params.current_fastq_raw}"
   mkdir "${params.current_fastp_reads}"
   mkdir "${params.current_fasta_reads}"
   mkdir "${params.current_snv_phyl_parsed_snvtable_dir}"
   mkdir "${params.current_fastqc_dir}"
  fi

  if ! [ -d "${params.current_partage_basedir}" ]
    then
    mkdir "${params.current_partage_basedir}"
  fi

  if ! [ -d "${params.current_partage_basedir_snv_phyl}" ]
    then
    mkdir "${params.current_partage_basedir_snv_phyl}"
  fi

   touch "make_directory_done.txt"
  """

}

//BIOIN-1054
process PREPARE_SAMPLE_SHEET{

  publishDir "${params.current_out_dir}", mode: 'copy',   pattern: "sample_sheet.tsv"

  input:
  path(samples_list_file)
  path(makedir_flag_file)
  path(samples_index_file)

  output:
  path("sample_sheet.tsv"), emit: sample_sheet

  script:

  """
  #echo "IN PREPARE_SAMPLE_SHEET"
  #echo "${samples_list_file}"
  #echo "${makedir_flag_file}"
  #echo "${samples_index_file}"

  build_samples_sheet.py --sample-list-file "${samples_list_file}"  --sample-index-file "${samples_index_file}"
  """

}

//BIOIN-1054
process IMPORT_FASTQ{
  input:
  path(sample_sheet)

  script:

  """
  #echo "IN IMPORT_FASTQ"
  import_fastq.py --sample-sheet "${sample_sheet}"  --nextseq-rawdata-basedir "${params.nextseq_rawdata_basedir}"  --fastq-dir  "${params.current_fastq_raw}"
  """

}


