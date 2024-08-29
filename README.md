## Phylogénétique Single Nucleotide Variant (SNV)
### Sommaire
Ce pipeline Nextflow déployé sur la grappe de calcul slurm génère des arbres phylogénétiques basées sur les SNV (Singel nucleotid Variant) extraits des données de séquencage brutes (fastq.gz) d'un ensemble de souches à analyser. Deux sous-approches ont été intégrées dans le pipeline.
L'une est basée sur les kmer et ne nécessite pas de génome de référence. Elle est implémenté dans l'outil [kSNP3](https://sourceforge.net/projects/ksnp/files/) L'autre utilisé plutôt l'approche implémentée dans [SNVPhyl](https://github.com/phac-nml/snvphylnfc?tab=readme-ov-file) consiste plutôt à aligner les reads sur un génome de référence et identifier les sites contenant au moins un nucléotide variant de haute qualité par rapport au génome de référence.  Dans les deux cas un pseudo-alignement multiple est produit et est utilisé en entrée pour produire un arbre phylogénétique. L'algorithme utilisé par kSNP3 est le Maximum de parcimonie (MP) contrairement à SNVPhyl qui utilise le Maximum de vraisemblance (ML). Les fichiers de sortie de SNVPhyl permettant également de construire un minimum spanning tree (MST) lquel peut-être visualisé dans [GrapeTree](https://github.com/achtman-lab/GrapeTree)




