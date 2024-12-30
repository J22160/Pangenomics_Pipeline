#====================================================================== preprocessing.smk =========================================================================================================

# Overview:  
# This Snakemake rule automates the preprocessing of sequencing data generated from both short-read (Illumina) and long-read (Oxford Nanopore Technologies, PacBio, etc.) platforms.  
# Preprocessing is a critical first step in genomic workflows to ensure high-quality data for downstream analysis, such as alignment, assembly, variant calling, and transcriptomics studies.  
# This pipeline standardizes the preprocessing workflow, allowing for reproducibility, scalability, and efficient resource utilization.  

# Key Steps:  
# 1. Adapter and Quality Trimming for Short Reads:  
#    - Removes adapter contamination and trims low-quality bases from paired-end short-read data using the `fastp` tool.  
#    - Trimming parameters such as minimum read length, mean quality score, and base quality thresholds are configurable via a `config.yaml` file.  
#    - The trimmed reads are output in gzip-compressed FASTQ format for downstream compatibility.  
#    - Logs and benchmarking files are generated to monitor the trimming process for each sample.  

# 2. Post-Trimming Quality Assessment for Short Reads:  
#    - Performs a comprehensive quality check of the trimmed reads using `FastQC`.  
#    - Outputs HTML reports for visual inspection of read quality, GC content, sequence duplication, and other metrics to ensure that trimming improves data quality.  
#    - Benchmarking and log files are generated for performance tracking and troubleshooting.  

# 3. Adapter Trimming for Long Reads:  
#    - Uses the `Porechop` tool to remove adapter sequences from long-read sequencing data, ensuring high-quality reads for assembly and alignment.  
#    - The output is a gzip-compressed FASTQ file containing trimmed reads.  
#    - As with short-read processing, this step also includes logging and benchmarking for reproducibility and performance evaluation.  

#  Usage Instructions:  
# - Edit configuration file (`configs/config.yaml`) with the desired parameters for `fastp`.  

#=====================================================================================================================================================================================================



# Rule for trimming short reads
rule short_read_trimming:
    """
    Trims adapter sequences and low-quality bases from paired-end short reads using the `fastp` tool.
    The trimming is performed on both the forward (read1) and reverse (read2) reads with specified quality 
    thresholds and minimum length requirements. The output is written to gzipped FASTQ files.
    """

    input:
        read1= os.path.join(short_read_dir, "{sample}_1.fastq.gz"),
        read2= os.path.join(short_reads_dir, "{sample}_2.fastq.gz")

    output:
        trim_read1= "output/clean_short_reads/{sample}_trimmed_1.fastq.gz",
        trim_read2= "output/clean_short_reads/{sample}_trimmed_2.fastq.gz"

    log:
        "logs/trim/short_reads/{sample}_trim.log"

    params:
        qualified_quality_phred= config["fastp"]["qualified_quality_phred"],
        mean_quality= config["fastp"]["cut_mean_quality"],
        length_required= config["fastp"]["min_length_required"]

    benchmark:
        "output/benchmarks/short_read_trim/{sample}.trim.benchmark.txt"

    threads: 8

    conda:
        "environments/fastp.yaml"

    shell:
        """
        # Running `fastp` to perform quality trimming on both read1 and read2.
        fastp --in1 {input.read1} \
        --in2 {input.read2} \
        --out1 {output.trim_read1} \
        --out2 {output.trim_read2} \
        --qualified_quality_phred {params.qualified_quality_phred} \
        --cut_mean_quality {params.mean_quality} \
        --length_required {params.length_required} \
        --overrepresentation_analysis \
        --thread {threads} > {log} 2>&1
        """

# Rule for post-trimming quality control of short reads using fastQC
rule short_read_post_trim_fastqc:
    """
    Performs post-trimming quality control using `FastQC` on the cleaned, trimmed short reads.
    This step generates HTML reports for both the forward (read1) and reverse (read2) reads to assess
    the quality after trimming.
    """

    input:
        clean_read1= "output/clean_short_reads/{sample}_trimmed_1.fastq.gz",
        clean_read2= "output/clean_short_reads/{sample}_trimmed_2.fastq.gz"

    output:
        html_r1= "output/clean_short_reads_fastqc/{sample}_1_fastqc.html",
        html_r2= "output/clean_short_reads_fastqc/{sample}_2_fastqc.html"

    log:
        "logs/qc/short_reads_trim/{sample}.log"

    benchmark:
        "output/benchmarks/short_read_trim_qc/{sample}.trim_qc.benchmark.txt"

    conda:
        "environments/fastqc.yaml"

    shell:
        """
        # Creating directory for FastQC output and running FastQC on the trimmed reads.
        mkdir -p output/clean_short_reads_fastqc/ &&  
        fastqc {input.clean_read1} {input.clean_read2} \
        --outdir output/clean_short_reads_fastqc/ > {log} 2>&1
        """

# Rule for trimming long read adapters using porechop 
rule long_read_adapter_trimming:
    """
    Trims adapter sequences from long RNA-Seq reads using the `Porechop` tool. This step is essential for
    removing adapter sequences from Oxford Nanopore or Pacific Biosciences long reads before downstream analyses.
    """

    input:
        long_reads= os.path.join(long_reads_dir, "{sample}.fastq.gz")

    output:
        trimmed_reads= "output/clean_long_reads/{sample}_chop.fastq.gz"

    log:
        "logs/trim/long_reads/{sample}_trim.log"

    benchmark:
        "output/benchmarks/long_read_trim/{sample}.trim.benchmark.txt"

    conda:
        "environments/porechop.yaml"

    threads: 8

    shell:
        """
        mkdir -p output/clean_long_reads && 
        porechop -i {input.long_reads} -o {output.trimmed_reads} --threads {threads} > {log} 2>&1
        """
