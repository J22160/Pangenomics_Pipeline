#======================================= pan_transcriptomics.smk ==================================================================

#   Overview: 
#   This Snakemake rule is designed for pan-transcriptomics analysis using Salmon.  
#   It includes essential steps such as creating an index from the pan-genome reference, performing transcript quantification  
#   with paired-end RNA-Seq data, and merging quantified counts into a consolidated matrix for downstream analysis.  
#   The goal is to enable efficient transcriptomic profiling across microbial pangenomes, tailored for comparative genomics  
#   and functional gene expression studies. 

#   Pan-transcriptomics involves studying gene expression across a pangenome, capturing both core and accessory genes. 
#   Accessory genes contribute to strain-specific traits, such as virulence or antibiotic resistance. 
#   By mapping RNA-Seq data to a pangenome instead of a single reference genome, we capture the full genetic diversity, allowing 
#   for more accurate insights into the functional potential of different strains.
#
# Key Features of the Workflow:  
#  1. Salmon Index Creation:  
#     - Generates a Salmon index from a pan-genome FASTA file, enabling transcript-level quantification.  
#
#  2. Transcript Quantification:  
#     - Quantifies expression levels for paired-end RNA-Seq reads, accounting for sequence biases, GC content, and fragment length.  
#     - Outputs quantification results for each sample in individual directories.  
#
#  3. Count Matrix Merging:  
#     - Aggregates transcript-level quantification across samples into a unified TPM count matrix for downstream analysis.  
#
#  Reusability:  
#  The workflow is modular and parameterized, making it adaptable to any microbial dataset requiring transcriptomic analysis  
#  in a pan-genome context. It relies on Salmon, a robust and fast tool for transcript-level quantification.  

#==================================================================================================================================


# Rule to create a Salmon index
rule salmon_index:
    
    input:
        reference="output/pangenome_analysis/pan_genome_reference.fa"
    
    output:
        directory= "output/pangenome_index"
    
    threads: 8

    conda: 
        "environments/salmon.yaml"

    shell:
        """
        mkdir -p {output.directory} &&
        salmon index -t {input.reference} -i {output.directory}
        """

# Rule to perform Salmon quantification
rule salmon_mapping:
    
    input:
        fastq_r1= "output/clean_short_reads/{sample}_trimmed_1.fastq.gz" ,
        fastq_r2= "output/clean_short_reads/{sample}_trimmed_2.fastq.gz",
        index= "output/pangenome_index"
    
    output:
        quant_dir="output/salmon_mapping/counts"
    
    params:
        sam= "output/salmon_mapping/alignment/{sample}.sam"
    
    threads: 16

    conda:
        "environments/salmon.yaml"

    benchmark:
        "output/benchmarks/salmon_mapping/{sample}.salmon.benchmark.txt"

    log:
        "logs/salmon_mapping/{sample}.salmon.mapping.log"

    shell:
        """
        mkdir -p output/salmon_mapping/counts &&
        salmon quant -i {input.index} \
                     -l A \
                     -1 {input.fastq_r1} \
                     -2 {input.fastq_r2}
                     -o {output.quant_dir} \
                     --validateMappings \
                     --gcBias \
                     --seqBias \
                     --writeUnmappedNames={params.sam} > {log} 2>&1
        """


rule salmon_count_merge:

    input: 
        sample="output/salmon_mapping/counts/{sample}"

    output:
        counts="output/sample_mapping/merge_salmon_counts_TPM.txt"

    threads: 4

    params:
        column= config["salmon"]["column"]
    
    conda:
        "environments/salmon.yaml"

    run:
        """
        salmon quant-merge -o {output.counts} -i {input.sample} --column={params.column} > {log} 2>&1
        """

    