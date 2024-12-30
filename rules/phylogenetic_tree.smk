# ===================================================== phylogenetic_tree.smk ===================================================================================================
#
#   Overview:
#   This Snakemake rule is designed for performing SNP analysis and constructing a phylogenetic tree based on core gene alignments from a pangenome analysis. 
#   By identifying single nucleotide polymorphisms (SNPs) from aligned sequences, this provides insights into genetic variation between strains. 
#   Additionally, constructing a phylogenetic tree based on these variations allows for visualizing the evolutionary relationships between strains, 
#   helping to understand their genetic diversity and evolutionary history.
#
#   Key Features:
#       1. SNP Analysis:
#             -Uses the snp-sites tool to detect SNPs from a core gene alignment, outputting the results in a directory for downstream analysis.
#             -The alignment input is typically derived from a pangenome analysis, ensuring that all core genes across strains are considered for SNP identification.
#       2. Phylogenetic Tree Construction:
#             -The iqtree tool is used to generate a phylogenetic tree based on the core gene alignment.
#             -The tree is built using the General Time Reversible model with Gamma distribution (+G) and bootstrapping (1000 replicates), 
#              providing a robust representation of the evolutionary relationships between the strains.

# ================================================================================================================================================================================


rule snp_analysis:
    
    input:
        aln= "output/pangenome_analysis/core_gene_alignment.aln"
    
    output:
        dir= "output/snp_analysis" 
    
    log:
        "logs/snp_sites/snp.analysis.log"

    conda:
        "environments/snp_sites.yaml"
    
    shell:
        """
        mkdir -p {output.dir} &&
        snp-sites -mp -o {output.dir} {input.aln} > {log} 2>&1
        """

rule phylogenetic_tree:

    input:
        aln= "output/pangenome_analysis/core_gene_alignment.aln"
    
    output:
        dir= "output/snp_analysis"
    
    conda:
        "iqtree.yaml"
    
    shell:
        """
        iqtree -s {input.aln} -m GTR+G -bb 1000 -nt AUTO
        """