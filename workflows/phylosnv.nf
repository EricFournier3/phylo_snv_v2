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
include {CLEAN_OUT; CLEAN_WORK; CLEAN_SNVPHYL_WORK}  from '../modules/clean/main'

// Color of text
ANSI_RESET = "\u001B[0m"
ANSI_RED = "\u001B[31m"
ANSI_GREEN = "\u001B[32m"
ANSI_YELLOW = "\u001B[33m";



workflow TEST_WF {

  workflow_name = "TEST_WF"

  println(ANSI_GREEN + """\
         \n
          ======================== 
            WORKFLOW ${workflow_name}
          ========================
         """.stripIndent()
         + ANSI_RESET) 
  TEST()

  workflow.onComplete {
     ANSI_YELLOW = "\u001B[33m"
     ANSI_RESET = "\u001B[0m"
     println ( ANSI_YELLOW +  """ termine   ${workflow_name}"""   + ANSI_RESET)
  }
}
  

workflow PREPARE_WF {

  workflow_name = "PREPARE_WF"

  println(ANSI_GREEN + """\
         \n
          =============================================== 
                       WORKFLOW ${workflow_name}
                          => PROCESS <=
                             ------- 
                          - MAKE_DIRECTORIES 
                          - IMPORT_FASTQ   
          ===============================================
                      >> INPUT PARAMETERS <<

                         Species                             : ${params.species} 
                         Output directory                    : ${params.current_out_dir}
                         Partage output directory            : ${params.partage_basedir}

         """.stripIndent()
         + ANSI_RESET) 

  MAKE_DIRECTORIES(params.species,params.out_basedir,params.outdir_name)
  IMPORT_FASTQ(params.sample_sheet_in,MAKE_DIRECTORIES.out.flag_file)

  workflow.onComplete {
     ANSI_YELLOW = "\u001B[33m"
     ANSI_RESET = "\u001B[0m"
     println ( ANSI_YELLOW +  """ ================= Fin du WORKFLOW ${workflow_name} ==================="""   + ANSI_RESET)
  }
}

workflow KSNP3_WF {

  workflow_name = "KSNP3_WF"

  println(ANSI_GREEN + """\
         \n
          =============================================== 
                         WORKFLOW ${workflow_name}
                           => PROCESS <= 
                              -------
                             - INDEX_REF 
                             - FASTP   
                             - BWA    
                             - SAMTOOLS_STATS 
                             - FASTQC 
                             - MULTIQC  
                             - FASTQ_TO_FASTA  
                             - BUILD_READS_FASTA_LIST  
                             - KSNP3 
                             - COMPUTE_KSNP3_DISTANCE_MATRIX 
                             - MAKE_SNV_PHYL_SAMPLESHEET 
          ===============================================
                      >> INPUT PARAMETERS <<

                         Species                             : ${params.species} 
                         Output directory                    : ${params.current_out_dir}
                         Partage output directory            : ${params.partage_basedir}

         """.stripIndent()
         + ANSI_RESET) 

  fastq_pair_channel = channel.fromFilePairs("${params.current_fastq_raw}" + '/*_S*_L001_{R1,R2}_001.fastq.gz')

  //TODO REACTIVER
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

  //TODO REACTIVER
  SAMTOOLS_STATS(BWA.out.bam_output,INDEX_REF.out.reference_fasta)


  //TODO REACTIVER
  fastq_raw_fastp_combined_channel = fastq_pair_channel.combine(FASTP.out.fastq_paired,by:0)


  //TODO REACTIVER
  FASTQC(fastq_raw_fastp_combined_channel)

  //TODO REACTIVER
  qc_channel = FASTP.out.fastp_json.mix(SAMTOOLS_STATS.out.samtools_out,FASTQC.out.fastqc_out).collect()

  //qc_channel.view {it -> "QC CHANNEL ${it}"}

  //TODO REACTIVER
  MULTIQC(qc_channel)


  //TODO REACTIVER
  FASTQ_TO_FASTA(FASTP.out.fastq_paired)

  //TODO REACTIVER
  BUILD_READS_FASTA_LIST(FASTQ_TO_FASTA.out.fasta_out.collect())

  //TODO REACTIVER
  KSNP3(BUILD_READS_FASTA_LIST.out.ksnp3_samples_list)

  //TODO REACTIVER
  COMPUTE_KSNP3_DISTANCE_MATRIX(KSNP3.out.ksnp3_alignment)

  //FASTP.out.fastq_paired.collect().view {it -> "FASTP OUT COLLECT ${it}"}

  //TODO REACTIVER
  //BIOIN-1051
  MAKE_SNV_PHYL_SAMPLESHEET(FASTP.out.fastq_paired.collect(),BUILD_READS_FASTA_LIST.out.rejected_samples_file)
  //MAKE_SNV_PHYL_SAMPLESHEET(FASTP.out.fastq_paired,BUILD_READS_FASTA_LIST.out.rejected_samples_file)

  workflow.onComplete {
     ANSI_YELLOW = "\u001B[33m"
     ANSI_RESET = "\u001B[0m"
     println ( ANSI_YELLOW +  """ ================= Fin du WORKFLOW ${workflow_name} ==================="""   + ANSI_RESET)
  }

}

workflow PARSE_SNVPHYL_OUTPUT_WF {

  workflow_name = "PARSE_SNVPHYL_OUTPUT_WF"

  println(ANSI_GREEN + """\
         \n
          =============================================== 
                         WORKFLOW ${workflow_name}
                           => PROCESS <= 
                              -------
                             - PARSE_SNV_TABLE 
                             - MAKE_GRAPETREE_NEWICK
          ===============================================
                      >> INPUT PARAMETERS <<

                         Species                             : ${params.species} 
                         Output directory                    : ${params.current_out_dir}
                         Partage output directory            : ${params.partage_basedir}

         """.stripIndent()
         + ANSI_RESET) 

  //TODO REACTIVER
  PARSE_SNV_TABLE(channel.fromPath("${params.current_snv_phyl_table}"),"${params.current_snv_phyl_parsed_snvtable_dir}","${params.out_grapetree_base_name}","${params.species}","${params.species}")

  //TODO REACTIVER
  MAKE_GRAPETREE_NEWICK(PARSE_SNV_TABLE.out.grapetree_profile)

  workflow.onComplete {
     ANSI_YELLOW = "\u001B[33m"
     ANSI_RESET = "\u001B[0m"
     println ( ANSI_YELLOW +  """ ================= Fin du WORKFLOW ${workflow_name} ==================="""   + ANSI_RESET)
  }
}

workflow CLEAN_WF() {

  workflow_name = "CLEAN_WF"

  println(ANSI_GREEN + """\
         \n
          =============================================== 
                         WORKFLOW ${workflow_name}
                           => PROCESS <= 
                              -------
                             - PARSE_SNV_TABLE 
                             - MAKE_GRAPETREE_NEWICK
          ===============================================
                      >> INPUT PARAMETERS <<

                         Species                             : ${params.species} 
                         Output directory                    : ${params.current_out_dir}
                         Partage output directory            : ${params.partage_basedir}

         """.stripIndent()
         + ANSI_RESET) 

  CLEAN_OUT()
  CLEAN_SNVPHYL_WORK()


  workflow.onComplete {
     ANSI_YELLOW = "\u001B[33m"
     ANSI_RESET = "\u001B[0m"
     println ( ANSI_YELLOW +  """ ================= Fin du WORKFLOW ${workflow_name} ==================="""   + ANSI_RESET)
  }
}
