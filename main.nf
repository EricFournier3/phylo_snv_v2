#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TEST_WF; PREPARE_WF; KSNP3_WF;PARSE_SNVPHYL_OUTPUT_WF;CLEAN_WF } from './workflows/phylosnv'
 
workflow PHYLO_SNV_WF {

 if(params.myworflow == 'test'){
   TEST_WF ()
 }else if(params.myworflow == 'prepare'){
  PREPARE_WF()
 }else if(params.myworflow == 'ksnp3'){
  KSNP3_WF()
 }else if(params.myworflow == 'parse_snvphyl_output'){
  PARSE_SNVPHYL_OUTPUT_WF()
 }else if(params.myworflow == 'clean'){
  CLEAN_WF()
 }
else{
  println "NO WORKFLOW"
 }

}

workflow {
  PHYLO_SNV_WF ()
}



