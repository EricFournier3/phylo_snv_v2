process KSNP3 {
  executor 'local' //car tcsh n est pas install sur tout les noeuds. Le yum install ne fonctionne pas sur ces noeuds. Ne trouve pas le bon mirror
  errorStrategy 'ignore'

  input:
  path(genome_list_path)

  output:
  path("SNPs_all_matrix.fasta"), emit: ksnp3_alignment

  script:

  """
  #echo "IN KSNP3"

  command="kSNP3 -in ${genome_list_path} -outdir ${params.current_ksnp3_res_dir} -k ${params.ksnp3_kmer_length}"
  #TODO REACTIVER
  eval "\${command}"

  #TODO REACTIVER
  cp -r ${params.current_ksnp3_res_dir} ${params.current_partage_basedir}

  #echo "KSNP3 CURRENT DIR IS \$PWD"

  cp ${params.current_ksnp3_res_dir}/SNPs_all_matrix.fasta .
  """
}

process COMPUTE_KSNP3_DISTANCE_MATRIX {

  publishDir "${params.current_partage_basedir_ksnp3}", mode: 'copy'

  input:
  path(ksnp3_alignment)

  output:
  path("ksnp3_matrix_*_sites.csv")

  script:

  """
  #echo "IN COMPUTE_KSNP3_DISTANCE_MATRIX"  

  compute_ksnp3_distance_matrix.py --ksnp3-alignment ${ksnp3_alignment}

  """

}
