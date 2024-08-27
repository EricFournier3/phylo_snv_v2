#!/bin/bash

#commande
#./run.sh nextflow.config.lmicdadei|nextflow.config.<espece_bacterienne>

RED="\e[31m"
ENDCOLOR="\e[0m"

mode=""
phylo_snv_path=$PWD

nextflow_workdir=${phylo_snv_path}/work

if [[ "${phylo_snv_path}" =~ "devel" ]]
  then
  mode="devel"
else
  mode="soft"
fi

config_file_tmp=${1}
config_file=/data/${mode}/phylo_snv_v2/nextflow.config

if [ "${#config_file_tmp}" -eq 0 ] || ! [ -f "/data/${mode}/phylo_snv_v2/${config_file_tmp}" ] 
  then
  echo -e "${RED}Error: missing config file${ENDCOLOR}\n"
else
 cp_cmd="cp /data/${mode}/phylo_snv_v2/${config_file_tmp} ${config_file}"
 eval "${cp_cmd}"
fi

out_basedir=$(sed -n '/^out_basedir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/out_basedir//g" |  sed "s/\${params.mode}/${mode}/g") 

species=$(sed -n '/^species/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/species//g")

outdir_name=$(sed -n '/^outdir_name/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/outdir_name//g")

snv_phyl_res_dir=$(sed -n '/^snv_phyl_res_dir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/snv_phyl_res_dir//g")

snv_phyl_res_dir=${out_basedir}/${species}/${outdir_name}/${snv_phyl_res_dir}

base_partage_basedir=$(sed -n '/^base_partage_basedir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/base_partage_basedir//g")

current_partage_basedir="${base_partage_basedir}"/${species}/"${outdir_name}"

snv_phyl_samplesheet=$(sed -n '/^snv_phyl_samplesheet/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/^snv_phyl_samplesheet//g")
snv_phyl_samplesheet=${out_basedir}/${species}/${outdir_name}/${snv_phyl_samplesheet}

ref_basedir=$(sed -n '/^ref_basedir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/ref_basedir//g" | sed "s/\${params.mode}/${mode}/g")

#echo ${ref_basedir}

fasta_reference="${ref_basedir}/${species}.fasta"


#TODO DESACTIVER
exit 0

module purge
module load nextflow/24.04.4
export NXF_HOME=/data/${mode}/phylo_snv_v2/.nextflow
export NXF_OPTS='-Xms1g -Xmx4g'

current_wf="prepare"
#TODO PAS BESOIN DES NEXTFLOW REPORT ICI. CA CREE repertoire out dans partage et donc clonflit avec process MAKE_DIRECTORIES
#nextflow run main.nf -process.echo -profile slurm --myworflow ${current_wf} -with-report "${current_partage_basedir}"/nextflow_report/${current_wf}_report.html -with-timeline "${current_partage_basedir}"/nextflow_report/${current_wf}_timeline.html -with-dag "${current_partage_basedir}"/nextflow_report/${current_wf}_dag.html -with-trace  "${current_partage_basedir}"/nextflow_report/${current_wf}_trace.txt 

#TODO REACTIVER
nextflow run main.nf -process.echo -profile slurm --myworflow ${current_wf} 

current_wf="ksnp3"
#TODO REACTIVER
nextflow run main.nf -process.echo -profile slurm,with_report --myworflow ${current_wf} -with-report "${current_partage_basedir}"/nextflow_report/${current_wf}_report.html -with-timeline "${current_partage_basedir}"/nextflow_report/${current_wf}_timeline.html -with-dag "${current_partage_basedir}"/nextflow_report/${current_wf}_dag.html -with-trace  "${current_partage_basedir}"/nextflow_report/${current_wf}_trace.txt

cd /data/soft/snvphylnfc/

export NXF_HOME=/data/soft/snvphylnfc/.nextflow
export NXF_SINGULARITY_CACHEDIR=/data/soft/snvphylnfc/Singularity_Containers

current_wf="snvphyl"
cmd="nextflow run phac-nml/snvphylnfc -c /data/soft/snvphylnfc/myconf/myconfig.config -profile singularity --window_size 20 --density_threshold 2  --min_coverage_depth 15 --min_mean_mapping_quality 30 --snv_abundance_ratio 0.75   --input ${snv_phyl_samplesheet} --refgenome ${fasta_reference} --outdir ${snv_phyl_res_dir} -with-report "${current_partage_basedir}"/nextflow_report/${current_wf}_report.html -with-timeline "${current_partage_basedir}"/nextflow_report/${current_wf}_timeline.html -with-dag "${current_partage_basedir}"/nextflow_report/${current_wf}_dag.html -with-trace  "${current_partage_basedir}"/nextflow_report/${current_wf}_trace.txt"

#echo ${cmd}
#TODO REACTIVER
eval ${cmd}

cd "${phylo_snv_path}"
export NXF_HOME=/data/${mode}/phylo_snv_v2/.nextflow

current_wf="parse_snvphyl_output"

#TODO REACTIVER
nextflow run main.nf -process.echo -profile slurm,with_report --myworflow ${current_wf} -with-report "${current_partage_basedir}"/nextflow_report/${current_wf}_report.html -with-timeline "${current_partage_basedir}"/nextflow_report//${current_wf}_timeline.html -with-dag "${current_partage_basedir}"/nextflow_report/${current_wf}_dag.html -with-trace  "${current_partage_basedir}"/nextflow_report/${current_wf}_trace.txt

current_wf="clean"
#TODO REACTIVER
nextflow run main.nf -process.echo -profile slurm --myworflow ${current_wf}

rm_workdir_cmd="rm -r ${nextflow_workdir}"
#TODO REACTIVER
eval ${rm_workdir_cmd}



