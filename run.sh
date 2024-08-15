#!/bin/bash

#commande
#./run.sh

phylo_snv_path=$PWD

config_file=/data/devel/phylo_snv_v2/nextflow.config

out_basedir=$(sed -n '/^out_basedir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/out_basedir//g")

species=$(sed -n '/^species/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/species//g")

outdir_name=$(sed -n '/^outdir_name/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/outdir_name//g")

snv_phyl_res_dir=$(sed -n '/^snv_phyl_res_dir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/snv_phyl_res_dir//g")
snv_phyl_res_dir=${out_basedir}/${species}/${outdir_name}/${snv_phyl_res_dir}

snv_phyl_samplesheet=$(sed -n '/^snv_phyl_samplesheet/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/^snv_phyl_samplesheet//g")
snv_phyl_samplesheet=${out_basedir}/${species}/${outdir_name}/${snv_phyl_samplesheet}

ref_basedir=$(sed -n '/^ref_basedir/p' ${config_file} | sed "s/\"//g" |  sed -E "s/\s+//g" | sed "s/=//g" | sed "s/ref_basedir//g")
fasta_reference="${ref_basedir}/${species}.fasta"

module purge
module load nextflow/24.04.4
export NXF_HOME=/data/devel/phylo_snv_v2/.nextflow
export NXF_OPTS='-Xms1g -Xmx4g'

nextflow run main.nf -process.echo -profile slurm --myworflow prepare
nextflow run main.nf -process.echo -profile slurm --myworflow ksnp3

cd /data/soft/snvphylnfc/

export NXF_HOME=/data/soft/snvphylnfc/.nextflow
export NXF_SINGULARITY_CACHEDIR=/data/soft/snvphylnfc/Singularity_Containers

cmd="nextflow run phac-nml/snvphylnfc -c /data/soft/snvphylnfc/myconf/slurm.config -profile singularity --window_size 20 --density_threshold 2  --min_coverage_depth 15 --min_mean_mapping_quality 30 --snv_abundance_ratio 0.75   --input ${snv_phyl_samplesheet} --refgenome ${fasta_reference} --outdir ${snv_phyl_res_dir}"

eval ${cmd}

cd "${phylo_snv_path}"
export NXF_HOME=/data/devel/phylo_snv_v2/.nextflow

nextflow run main.nf -process.echo -profile slurm --myworflow parse_snvphy_output





