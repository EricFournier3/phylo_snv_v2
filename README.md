## Phylogénétique Single Nucleotide Variant (SNV)
### Sommaire
Ce pipeline Nextflow déployé sur la grappe de calcul slurm génère des arbres phylogénétiques basées sur les SNV (Singel nucleotid Variant) extraits des données de séquencage brutes (fastq.gz) d'un ensemble de souches à analyser. 




L’objectif du présent projet est de développer un pipeline d’analyse  basé sur les Single Nuclotide Variant (SNV) afin d'établir les liens évolutifs entres les différentes souches bactériennes à l'étude.  Deux approches sont intégrées dans le pipeline; 

 Approche sans génome de référence basée sur les kmer avec kSNP3: kSNP - Browse Files at SourceForge.net

Approche avec génome de référence avec SNVPhyl : Home - SNVPhyl

Les deux approches utilisent en entrée des fichiers brutes fastq.gz. Aucun assemblage de génomes n’est nécessaire. En résumé, kSNP3 va identifier les positions variantes en comparant les kmer homologues entres les isolats. 
Ces positions variantes sont extraites et utilisées pour produire un pseudo-alignement nucléotidique. Celui-ci est  ensuite utiliser pour construire un arbre phylogénétique avec l’algorithme de Maximum de parcimonie et calculer une matrice de distance. 

SNVPhyl va quand a lui aligner (reads mapping) les reads sur un génomes de référence et identifier les sites contenants au moins une variation par rapport à la référence. Tout comme kSNP3, ces sites sont concaténés en un pseuo-alignement 
multiple lequel est ensuite utiliser pour construire une arbre phylogénétique avec l’algorithme du Maximum de vraisemblance (ML) et calculer une matrice de distance. Les fichiers de sortie de SNVPhyl permettent également de construire un arbre
de type Minimum Spanning Tree (MST, Minimum spanning tree - Wikipedia) dans lequel les souches identiques sont regroupées dans un même cluster. L’application GrapeTree (achtman-lab/GrapeTree: GrapeTree is a fully interactive, tree visualization program, which
supports facile manipulations of both tree layout and metadata. Click the first link to launch: https://achtman-lab.github.io/GrapeTree/MSTree_holder.html) est conçu pour visualiser de tels arbres.

Dans ce qui suit est détaillé la structure du pipeline sur le serveur slurm ainsi que son mode de fonctionnement.
