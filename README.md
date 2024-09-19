## Phylogénétique Single Nucleotide Variant (SNV)
### Sommaire
Ce pipeline Nextflow déployé sur la grappe de calcul slurm génère des arbres phylogénétiques basées sur les SNV (Single nucleotid Variant) extraits des données de séquencage brutes (fastq.gz) d'un ensemble de souches à analyser. Deux sous-approches ont été intégrées dans le pipeline.
L'une est basée sur les kmer et ne nécessite pas de génome de référence. Elle est implémenté dans l'outil [kSNP3](https://sourceforge.net/projects/ksnp/files/) L'autre utilise plutôt l'approche implémentée dans [SNVPhyl](https://github.com/phac-nml/snvphylnfc?tab=readme-ov-file) et consiste plutôt à aligner les reads sur un génome de référence et identifier les sites contenant au moins un nucléotide variant de haute qualité par rapport au génome de référence.  Dans les deux cas un pseudo-alignement multiple est produit et est utilisé en entrée pour produire un arbre phylogénétique. L'algorithme utilisé par kSNP3 est le Maximum de parcimonie (MP). SNVPhyl qui utilise quant à lui l'approche probabiliste Maximum de vraisemblance (ML). Les fichiers de sortie de SNVPhyl permettent également de construire un minimum spanning tree (MST) lequel peut-être visualisé dans [GrapeTree](https://github.com/achtman-lab/GrapeTree)

### Flowchart
![Diagramme sans nom-1724944430911 drawio](https://github.com/user-attachments/assets/5cf56d4b-1fb9-42a7-b35d-ae00fb125666)

### Exécution du pipeline
#### Préparation
Avant d'éxécuter le pipeline, l'utilisateur doit ajuster/créer les deux fichiers suivants
- __nextflow.config.xxxxxx__  localisé dans /data/soft/phylo_snv_v2: xxxxxx étant l'identifiant spécifique à l'espèce bactérienne analysée. Modifier (au besoin) dans ce fichier tous les paramètres du bloc **params** qui ne son pas identifié par DO NOT CHANGE
- Une Samples sheet en format tsv placée dans /data/soft/phylo_snv_v2/samplesheet. Cette Samples sheet correspond à la valeur du paramètre **sample_sheet_in** du fichier de configuration nextflow.config.xxxxxx. Son format doit être le suivant:

| SAMPLE_NAME    | RUN     |
| --------       | ------- |
| Sample1        | RUN_A   |
| Sample2        | RUN_A   |
| Sample3        | RUN_B   |

La colonne RUN correspond aux runs de séquancage (données brutes uniquement) pacées dans /data/run_raw_data sur la grappe de calculs slurm

### Exécution
Se placer dans le répertoire /data/soft/phylo_snv_v2 et exécuter la commande suivante

```console
(base) [foueri01@inspq.qc.ca@slurm10p phylo_snv_v2]$ ./run.sh nextflow.config.xxxxxx
```
### Sortie du pipeline
Les résultats du pipeline sont produits dans deux emplacements; localement sur slurm et sur le serveur de fichiers au niveau de S:Partage

#### Sur slurm
Les données intermédiaires et les résultats finaux produits sur slurm sont sauvegardés dans 
```console
/data/soft/phylo_snv_v2/out/<species>/<outdir_name>
```
 \<species> et <outdir_name> étant respectivement la valeur des paramètre **species** et **outdir_name** dans le fichier de configuration nextflow.config.xxxxxx

 La structure interne de <outdir_name> est la suivante;
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
- FASTA_READS : Reads en format fasta. Un fichier fasta concaténé par spécimen (nettoyé à la fin du pipeline)
- FASTP_READS : Paires de fichiers fastq.gz après traitement par fastp (nettoyé à la fin du pipeline)
- FASTQC : Rapport de qualité fastq.gz avant et après le traitement fastp (nettoyé à la fin du pipeline)
- FASTQ_RAW : Reads fastq.gz brutes (nettoyé à la fin du pipeline)
- filtered_samples : Contient le fichier rejected_samples.txt avec la liste des échantillons non inclus dans l'analyse dû à un nombre insuffisant de reads (selon la valeur du paramètre **min_fastp_reads**)
- ksnp3_res : Contient les fichiers de résultats kSNP3. L'arbre phylogénétique parcimonieux d'intérêt est le tree_tipAlleleCounts.parsimony.tre
- ksnp3_samples_list.txt : Fichier liste de tous les spécimens en format input kSNP3
- ksnp3_samples_list_filtered.txt : Comme ksnp3_samples_list.txt mais sans les spécimens inclus dans rejected_samples.txt. C'est donc le fichier input final utilisé par kSNP3
- snv_phyl_samplesheet.csv : La Sample Sheet utilisée en input par SNVPhyl
- snv_phyl_res : Le répertoire de résultats SNVPhyl. Les fichiers volumineux sans intérêt sont supprimés à la fin du pipeline
- snv_phyl_parsed_snvtable : Contient les fichiers (grapetree-tree.nwk et grapetree-metadata.tsv) input pour GrapeTree issus du traitement du fichier snv_phyl_res/vcf2snv/snvTable.tsv produit par SNVPhyl

  #### Sur S:Partage
  Sur S:Partage, dans <base_partage_basedir>/\<species>/<outdir_name> ne sont produits et copiés que les résultats d'intérêt pour l'utilisateur. <base_partage_basedir>, \<species> , <outdir_name> correspondant respectivement aux valeurs de paramètres **base_partage_basedir**, **species** et **outdir_name** dans le fichiers de configuration nextflow.config.xxxxxx. L'organisation du sous répertoire <outdir_name> est la suivante;
  - ksnp3_res : Contient les fichiers de sortie de kSNP3. Les fichiers d'intérêt sont les suivants;
    * tree_tipAlleleCounts.parsimony.tre : l'arbre phylogénétique parcimonieux
    * ksnp3_matrix_NombreDeSites_sites.csv : la matrice de distance. NombreDeSites étant le nombre de sites dans le pseudo-alignement
  - snv_phyl_res : Contient les fichiers de sortie d'intérêt du workflow SNVPHYL_WF. 
    * grapetree-metadata.tsv : fichier indiquant à quel groupe appartient chacun des spécimens
    * grapetree-profile.tsv
    * grapetree-tree.nwk : le fichier arbre MST à visualiser dans GrapeTree
    * lmicdadei-profile.tsv
    * lmicdadei-strains.tsv
    * snvMatrix.tsv : la matrice de distance
    * phylogeneticTree.newick : l'arbre ML produit par SNVPhyl
    * phylogeneticTreeStats.txt : statistoques produites durant la production de phylogeneticTree.newick
  - multiqc_data : Contient le rapport global de qualité des données de séquencage
    * multiqc_report.html
  - nextflow_report : Contient les rapports statistique d'exécution des workflow Nextflow

      
  

