process CLEAN_OUT{


  script:

  """

  printf "\033[94m\033[107m------------ REMOVE FASTP READ --------------\033[0m\n\n" 
  fastp_reads_dir=${params.current_out_dir}/FASTP_READS/
  rm_cmd="rm \${fastp_reads_dir}*.fastq.gz"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}
  
  printf "\033[94m\033[107m------------ REMOVE FASTQC FILES --------------\033[0m\n\n" 
  fastqc_file_dir=${params.current_out_dir}/FASTQC/
  rm_cmd="rm \${fastqc_file_dir}*.html;rm \${fastqc_file_dir}*.zip"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}
  
  printf "\033[94m\033[107m------------ REMOVE FASTQ RAW --------------\033[0m\n\n" 
  fastq_raw_dir=${params.current_out_dir}/FASTQ_RAW/
  rm_cmd="rm \${fastq_raw_dir}*.fastq.gz"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}

  printf "\033[94m\033[107m------------ REMOVE SNVPHYL SMALT BAM --------------\033[0m\n\n" 
  snvphyl_smalt_bam_dir=${params.current_snv_phyl_res_dir}/smalt/
  rm_cmd="rm \${snvphyl_smalt_bam_dir}*.bam"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}

  printf "\033[94m\033[107m------------ REMOVE SNVPHYL BCFTOOLS FILES --------------\033[0m\n\n" 
  snvphyl_bcftools_files_dir=${params.current_snv_phyl_res_dir}/bcftools/
  rm_cmd="rm \${snvphyl_bcftools_files_dir}*.bcf"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}

  printf "\033[94m\033[107m------------ REMOVE SNVPHYL CONSOLIDATE FILES --------------\033[0m\n\n" 
  snvphyl_consolidate_files_dir=${params.current_snv_phyl_res_dir}/consolidate/
  rm_cmd="rm \${snvphyl_consolidate_files_dir}*.bcf;rm \${snvphyl_consolidate_files_dir}*.csi;rm \${snvphyl_consolidate_files_dir}*.txt"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}

  printf "\033[94m\033[107m------------ REMOVE SNVPHYL FILTERED VCF --------------\033[0m\n\n" 
  snvphyl_filtered_vcf_dir=${params.current_snv_phyl_res_dir}/filter/
  rm_cmd="rm \${snvphyl_filtered_vcf_dir}*.vcf"
  echo \${rm_cmd}
  #TODO REACTIVER
  #eval \${rm_cmd}
  """

}

process CLEAN_WORK{


  script:

  """
  echo "IN CLEAN_WORK"
  """

}

process CLEAN_SNVPHYL_WORK{


  script:

  """
  echo "IN CLEAN_SNVPHYL_WORK"
  """

}


