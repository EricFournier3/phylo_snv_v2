## Phylogénétique Single Nucleotide Variant (SNV)
### Sommaire
Ce pipeline Nextflow déployé sur la grappe de calcul slurm génère des arbres phylogénétiques basées sur les SNV (Single nucleotid Variant) extraits des données de séquencage brutes (fastq.gz) d'un ensemble de souches à analyser. Deux sous-approches ont été intégrées dans le pipeline.
L'une est basée sur les kmer et ne nécessite pas de génome de référence. Elle est implémenté dans l'outil [kSNP3](https://sourceforge.net/projects/ksnp/files/) L'autre utilisé plutôt l'approche implémentée dans [SNVPhyl](https://github.com/phac-nml/snvphylnfc?tab=readme-ov-file) consiste plutôt à aligner les reads sur un génome de référence et identifier les sites contenant au moins un nucléotide variant de haute qualité par rapport au génome de référence.  Dans les deux cas un pseudo-alignement multiple est produit et est utilisé en entrée pour produire un arbre phylogénétique. L'algorithme utilisé par kSNP3 est le Maximum de parcimonie (MP) contrairement à SNVPhyl qui utilise le Maximum de vraisemblance (ML). Les fichiers de sortie de SNVPhyl permettant également de construire un minimum spanning tree (MST) lquel peut-être visualisé dans [GrapeTree](https://github.com/achtman-lab/GrapeTree)

### Flowchart
![Diagramme sans nom-1724944430911 drawio](https://github.com/user-attachments/assets/d73d23b4-5533-4663-b008-d0e9c08702cf)

### Exécution du pipeline
#### Préparation
Avant d'éxécuter le pipeline, l'utilisateur doit ajuster les deux fichiers suivants
- __nextflow.config.xxxxxx__  localisé dans /data/soft/phylo_snv_v2: xxxxxx étant l'identifiant spécifique à l'espèce bactérienne analysée. Modifier (au besoin) dans ce fichier tous les paramètres du bloc params qui ne son pas identifié par DO NOT CHANGE
- Une Samples sheet en format tsv placée dans /data/soft/phylo_snv_v2/samplesheet. Cette Samples sheet correspond à la valeur du paramètre sample_sheet_in du fichier de configuration nextflow.config.xxxxxx. Son format doit être le suivant:

| SAMPLE_NAME    | RUN     |
| --------       | ------- |
| Sample1        | RUN_A   |
| Sample2        | RUN_A   |
| Sample3        | RUN_B   |

Les runs correspondent aux runs de séquancage (données brutes uniquement) pacées dans /data/run_raw_data

### Exécution
Se placer dans le répertoire /data/soft/phylo_snv_v2 et exécuter la commande suivante

```console
(base) [foueri01@inspq.qc.ca@slurm10p phylo_snv_v2]$ ./run.sh nextflow.config.xxxxxx
```
### Sortie du pipeline
Les résultats du pipeline sont produits à deux emplacements; localement sur slurm et sur le serveur de fichiers au niveau de S:Partage

#### Sur slurm
Les données intermédiaires et les résultats finaux produits sur slurm sont sauvegardés dans 
```console
/data/soft/phylo_snv_v2/out/<species>/<outdir_name>
```
 \<species> et <outdir_name> étant respectivement la valeur des paramètre __species__ et __outdir_name__ dans le fichier de configuration nextflow.config.xxxxxx

 La structure interne est la suivante;
 ```console
.
├── FASTA_READS
├── FASTP_READS
├── FASTQC
├── FASTQ_RAW
├── filtered_samples
├── ksnp3_res
├── ksnp3_samples_list_filtered.txt
├── ksnp3_samples_list.txt
├── snv_phyl_parsed_snvtable
├── snv_phyl_res
└── snv_phyl_samplesheet.csv
```

