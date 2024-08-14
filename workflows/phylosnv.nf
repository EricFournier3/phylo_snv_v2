include {TEST} from '../modules/test/main'
include {MAKE_DIRECTORIES; IMPORT_FASTQ} from '../modules/prepare/main'
include {FASTP} from '../modules/fastp/main'
include {FASTQC} from '../modules/fastqc/main'
include {FASTQ_TO_FASTA; BUILD_READS_FASTA_LIST; MAKE_SNV_PHYL_SAMPLESHEET} from '../modules/utils/main'
include {KSNP3} from '../modules/ksnp3/main'
include {PARSE_SNV_TABLE; MAKE_GRAPETREE_NEWICK}from '../modules/snvphyl_utils/main'

workflow TEST_WF {
  TEST()
}

workflow PREPARE_WF {
  MAKE_DIRECTORIES(params.species,params.out_basedir,params.outdir_name)
  IMPORT_FASTQ(params.sample_sheet_in,MAKE_DIRECTORIES.out.flag_file)
}

workflow KSNP3_WF {
  fastq_pair_channel = channel.fromFilePairs("${params.current_fastq_raw}" + '/*_S*_L001_{R1,R2}_001.fastq.gz')

  fastp_channel = FASTP(fastq_pair_channel)

  fastq_raw_fastp_combined_channel = fastq_pair_channel.combine(FASTP.out.fastq_paired,by:0)

  FASTQC(fastq_raw_fastp_combined_channel)

  FASTQ_TO_FASTA(FASTP.out.fastq_paired)

  BUILD_READS_FASTA_LIST(FASTQ_TO_FASTA.out.fasta_out.collect())

  KSNP3(BUILD_READS_FASTA_LIST.out.ksnp3_samples_list)

  MAKE_SNV_PHYL_SAMPLESHEET(FASTP.out.fastq_paired)

}

workflow PARSE_SNVPHYL_OUTPUT_WF {
  PARSE_SNV_TABLE(channel.fromPath("${params.current_snv_phyl_table}"),"${params.current_snv_phyl_parsed_snvtable_dir}","${params.out_grapetree_base_name}","${params.species}","${params.species}")

  MAKE_GRAPETREE_NEWICK(PARSE_SNV_TABLE.out.grapetree_profile)
}

