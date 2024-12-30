#============================================ hybrid_assembly.smk ======================================================

# Overview:  
# This Snakemake rule performs hybrid genome assembly using both short and long reads. Hybrid assembly leverages the high 
# accuracy of short reads and the long contiguity of long reads to generate high-quality, contiguous genome assemblies. 
# The assembly process is carried out using `Unicycler`, a robust tool for hybrid assembly that combines the advantages of 
# Illumina short-read sequencing with Oxford Nanopore or PacBio long-read sequencing.  
  

# - Input Reads: Utilizes preprocessed paired-end short reads (forward and reverse) and long reads after quality trimming.  
# - Output Assembly: Produces a FASTA file containing the assembled genome sequence. This output serves as the basis for 
#   further genome annotation, variant calling, or comparative genomics analyses.  

#=====================================================================================================================

# rule for performing hybrid assembly 
rule hybrid_assembly:
    
    input:
        clean_read_fr= "output/clean_short_reads/{sample}_trimmed_1.fastq.gz" ,
        clean_read_rr= "output/clean_short_reads/{sample}_trimmed_2.fastq.gz" ,
        long_read= "output/clean_long_reads/{sample}_chop.fastq.gz"
    
    output:
        fasta= "output/hybrid_assembly/{sample}/{sample}_assembly.fasta"

    log:
        "logs/hybrid_assembly/{sample}_unicycler.log""       
    
    params:
        path_dir= "output/hybrid_assembly/{sample}",
        keep = config["hybrid_assembly"]["keep"],
        verbosity = config["hybrid_assembly"]["verbosity"]
    
    benchmark:
        "output/benchmarks/hybrid_assembly/{sample}.hybrid.assembly.benchmark.txt"

    conda:
        "environments/unicycler.yaml"
    
    threads: 16
    
    shell:
        """    
        mkdir -p {params.path_dir} &&
        unicycler -1 {input.clean_read_fr} \
        -2 {input.clean_read_rr} \
        -l {input.long_read} \
        --out {params.path_dir} \
        --keep {params.keep} \
        --verbosity {params.verbosity} \
        --threads {threads} > {log} 2>&1
        """
