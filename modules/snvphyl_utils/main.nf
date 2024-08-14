process PARSE_SNV_TABLE {

  publishDir "${params.current_snv_phyl_parsed_snvtable_dir}", mode: 'copy'

  input:
  path(snvtable)
  val(mybasedir_out)
  val(myout_grapetree_base_name)
  val(myref_name)
  val(myout_base_name)

  output:
  path("${myout_grapetree_base_name}-profile.tsv"), emit: grapetree_profile
  path("${myout_base_name}-profile.tsv"), emit: profile
  path("${myout_base_name}-strains.tsv"), emit: strains
  path("${myout_grapetree_base_name}-metadata.tsv"), emit: grapetree_strains

  script:
  
  """
  echo "IN PARSE_SNV_TABLE"
  parse_snvtable.py  --snv-table "${snvtable}" --ref-name "${myref_name}" --out-base-name "${myout_base_name}" --out-grapetree-base-name "${myout_grapetree_base_name}" --basedir-out "${params.current_snv_phyl_parsed_snvtable_dir}"

  """

}

process MAKE_GRAPETREE_NEWICK {
  publishDir "${params.current_snv_phyl_parsed_snvtable_dir}", mode: 'copy'

  input:
  path(grapetree_profile)

  output:
  path("grapetree-tree.nwk")

  script:
  """
  echo "IN MAKE_GRAPETREE_NEWICK"

  grapetree.py -p "${grapetree_profile}" -m MSTreeV2 > grapetree-tree.nwk

  """

}
