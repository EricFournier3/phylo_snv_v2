include {TEST} from '../modules/test/main'
include {MAKE_DIRECTORIES; IMPORT_FASTQ} from '../modules/prepare/main'
include {FASTP} from '../modules/fastp/main'
include {FASTQC} from '../modules/fastqc/main'
include {FASTQ_TO_FASTA; BUILD_READS_FASTA_LIST} from '../modules/utils/main'
include {KSNP3; COMPUTE_KSNP3_DISTANCE_MATRIX} from '../modules/ksnp3/main'
include {PARSE_SNV_TABLE; MAKE_GRAPETREE_NEWICK; MAKE_SNV_PHYL_SAMPLESHEET} from '../modules/snvphyl_utils/main'
include {BWA; INDEX_REF} from '../modules/bwa/main'
include {SAMTOOLS_STATS} from '../modules/samtools/main'
include {MULTIQC} from '../modules/multiqc/main'


workflow TEST_WF {
  TEST()
}

workflow PREPARE_WF {
  MAKE_DIRECTORIES(params.species,params.out_basedir,params.outdir_name)
  IMPORT_FASTQ(params.sample_sheet_in,MAKE_DIRECTORIES.out.flag_file)
}

workflow KSNP3_WF {
  fastq_pair_channel = channel.fromFilePairs("${params.current_fastq_raw}" + '/*_S*_L001_{R1,R2}_001.fastq.gz')

  INDEX_REF("${params.ref_basedir}/${params.species}.fasta")
  //INDEX_REF.out.reference_fasta.view {it -> {"ref is ${it[0]} and  ann id ${it[2]}"}}

  //TODO REACTIVER
  FASTP(fastq_pair_channel)
  
  //TODO PAS BESOIN DE LA LIGNE SUIVANTE
  //fastp_channel = FASTP(fastq_pair_channel)

  //FASTP.out.fastq_paired.view {it -> "${it}"} 

  //TODO REACTIVER
  BWA(FASTP.out.fastq_paired,INDEX_REF.out.reference_fasta) 

  //BWA.out.bam_output.view {it -> "SAMPLE IS ${it[0]} and BAM IS ${it[1]}"}

  SAMTOOLS_STATS(BWA.out.bam_output,INDEX_REF.out.reference_fasta)


  //TODO REACTIVER
  fastq_raw_fastp_combined_channel = fastq_pair_channel.combine(FASTP.out.fastq_paired,by:0)


  //TODO REACTIVER
  FASTQC(fastq_raw_fastp_combined_channel)

  //TODO REACTIVER
  qc_channel = FASTP.out.fastp_json.mix(SAMTOOLS_STATS.out.samtools_out,FASTQC.out.fastqc_out).collect()

  //qc_channel.view {it -> "QC CHANNEL ${it}"}

  MULTIQC(qc_channel)


  //TODO REACTIVER
  FASTQ_TO_FASTA(FASTP.out.fastq_paired)

  //TODO REACTIVER
  BUILD_READS_FASTA_LIST(FASTQ_TO_FASTA.out.fasta_out.collect())

  //TODO REACTIVER
  KSNP3(BUILD_READS_FASTA_LIST.out.ksnp3_samples_list)

  COMPUTE_KSNP3_DISTANCE_MATRIX(KSNP3.out.ksnp3_alignment)

  //TODO REACTIVER
  MAKE_SNV_PHYL_SAMPLESHEET(FASTP.out.fastq_paired)

}

workflow PARSE_SNVPHYL_OUTPUT_WF {
  PARSE_SNV_TABLE(channel.fromPath("${params.current_snv_phyl_table}"),"${params.current_snv_phyl_parsed_snvtable_dir}","${params.out_grapetree_base_name}","${params.species}","${params.species}")

  MAKE_GRAPETREE_NEWICK(PARSE_SNV_TABLE.out.grapetree_profile)
}

