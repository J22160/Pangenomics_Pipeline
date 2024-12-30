# ===================================================================================================
#                       Pangenomics and Pan-Transcriptomics Analysis Pipeline Snakefile
# ===================================================================================================
#   Author: Jash Trivedi
#   Date: 12/28/2024
#   Project: Pangenome and Pan-Transcriptome Analysis Pipeline
#
#   Description:
#   This Snakefile is the central orchestrator for a comprehensive pipeline designed to analyze 
#   the pangenomics and pan-transcriptomics of microbial genomes. It leverages short- and long-read 
#   sequencing data to assemble, annotate, and extract valuable insights into the genomic 
#   architecture and transcriptomic variations across strains. The modular design of the pipeline 
#   facilitates customization and scalability for various input configurations and analysis requirements.
#
#   Key Features:
#       - Data Preprocessing: Trimming of adapters and low-quality reads for both short- and long-read sequencing data to ensure high-quality input for downstream analyses.
#       - Hybrid Genome Assembly: Combines short- and long-read sequencing data for improved genome assembly completeness and accuracy.
#       - Functional Annotation: Uses Prokka to annotate assembled genomes, producing standardized output files for downstream functional and comparative analyses.
#       - Pangenome Analysis: Identifies core and accessory genes using a high-resolution pangenome analysis framework, incorporating polishing and sample name integration for downstream compatibility.
#       - Transcriptome Quantification: Employs Salmon for transcript-level quantification and aggregates expression data across samples for comparative transcriptomics.
#       - SNP Analysis and Phylogenetic Tree Construction: Detects single nucleotide polymorphisms (SNPs) across strains and uses this information to construct phylogenetic trees, providing insights into 
#         genetic variation, evolutionary relationships, and strain divergence
#       
#   Input:
#       - Short-read FASTQ files stored in the directory specified in the configuration file.
#       - Long-read FASTQ files stored in the designated directory from the configuration file.
#       - Configuration file (`configs/config.yaml`) specifying parameters such as input directories, 
#         reference genome paths, and other essential resources.
#
#   Output:
#       - Trimmed FASTQ files for both short- and long-read data.
#       - Hybrid genome assemblies for each sample.
#       - Functional annotations in GFF format for each assembled genome.
#       - Comprehensive pangenome analysis outputs, including polished pangenomes and essential metadata.
#       - Transcript-level abundance quantifications (TPM) for pan-transcriptomic analyses.
#       - SNP analysis results for genomic variation studies.
#       - MultiQC reports consolidating all quality control metrics.
#
#   Rules:
#       - `preprocessing.smk`: Performs trimming of short-read and long-read sequencing datasequencing data for  to ensure high-quality inputs.
#       - `hybrid_assembly.smk`: Generates hybrid genome assemblies by combining short- and long-read sequencing data for each sample.
#       - `assembly_annotation.smk`: Annotates the assembled genomes using Prokka, providing functional and structural insights.
#       - `pangenome_analysis.smk`: Executes a comprehensive pangenome analysis, including polishing and refining core and accessory gene data.
#       - `pan_transcriptomics.smk`: Quantifies transcript abundance across samples using Salmon for pan-transcriptomic analysis.
#       - `phylogenetic_tree.smk`: Identifies single nucleotide polymorphisms (SNPs) across strains and constructs phylogenetic trees to explore evolutionary relationships.
#       - `multiqc_report.smk`: Consolidates quality control and mapping results into a comprehensive MultiQC report for streamlined data assessment.
#
#   Usage:
#       - Modify the configuration file (`configs/config.yaml`) according to project specifications.
#       - Execute the pipeline with the following command:
#        `snakemake --sdm conda --cores <num_cores>` to utilize available computational resources efficiently.
# =======================================================================================================

# Load configuration file
configfile: "configs/config.yaml"

# Input directories for short- and long-read data
short_read_dir = config["SHORT_READ_DIRECTORY"]
long_read_dir = config["LONG_READ_DIRECTORY"]

# Identify samples from short-read FASTQ files
SAMPLE, FRR = glob_wildcards(os.path.join(short_read_dir, "{sample}_{frr}.fastq.gz"))
sorted_sample = sorted(SAMPLE)
SAM = list(set(sorted_sample))

# The final output targets for the pipeline
rule all:
    input:
        # Trimmed short-read files and quality reports
        short_read_trimming_r1=expand("output/clean_short_reads/{sample}_trimmed_1.fastq.gz", sample=SAM),
        short_read_trimming_r2=expand("output/clean_short_reads/{sample}_trimmed_2.fastq.gz", sample=SAM),
        short_read_post_trim_fastqc_html1=expand("output/clean_short_reads_fastqc/{sample}_1_fastqc.html", sample=SAM),
        short_read_post_trim_fastqc_html2=expand("output/clean_short_reads_fastqc/{sample}_2_fastqc.html", sample=SAM),
        
        # Trimmed long-read files
        long_read_adapter_trimming=expand("output/clean_long_reads/{sample}_chop.fastq.gz", sample=SAM),
        
        # Hybrid genome assemblies
        hybrid_assembly=expand("output/hybrid_assembly/{sample}/{sample}_assembly.fasta", sample=SAM),
        
        # Functional annotations
        prokka_annotation=expand("output/annotation_prokka/{sample}/{sample}.gff", sample=SAM),
        
        # Input GFF files for pangenome analysis
        gff_file=expand("output/input_gff/{sample}.gff", sample=SAM),
        
        # Pangenome analysis results
        pangenome_analysis=expand("output/pangenome_analysis/"),
        sample_names=expand("output/pangenome_analysis/needed_sample_names.txt"),
        pangenome_polish=expand("output/pangenome_analysis/pangenome_polished"),
        
        # Transcript quantification and merging
        salmon_mapping=expand("output/salmon_mapping/counts"),
        salmon_count_merge=expand("output/sample_mapping/merge_salmon_counts_TPM.txt"),
        
        # SNP analysis
        snp_analysis=expand("output/snp_analysis"),
        
        # Comprehensive quality control report
        multiqc_report=expand("output/multiqc/multiqc_report.html")
 

