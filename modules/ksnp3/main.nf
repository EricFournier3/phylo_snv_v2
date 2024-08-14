process KSNP3 {
  errorStrategy 'ignore'

  input:
  path(genome_list_path)

  script:

  """
  echo "IN KSNP3"

  command="kSNP3 -in ${genome_list_path} -outdir ${params.current_ksnp3_res_dir} -k 19 | tee ${params.current_ksnp3_res_dir}/mylog.txt"
  eval "\${command}"
  """
}
