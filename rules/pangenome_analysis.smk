# =============================================== pangenome_analysis.smk =====================================================
# Overview  
# This Snakemake rule provides a complete and streamlined pipeline for pangenome analysis. It encompasses critical step 
# performing pangenome construction using `Panaroo`, and polishing the resulting pangenome with `Clarc`. 
# The workflow is designed to deliver a high-quality, reproducible pangenome analysis tailored to microbial genomics.

# Key Features

# 1. File Management
# Centralized Organization:  
#  GFF files generated during genome annotation are copied to a designated directory for seamless downstream processing.  
# Sample Tracking:  
#  Automatically extracts sample names from the GFF files, creating a reference list for efficient sample management and analysis.

# 2. Pangenome Analysis
# Robust Construction with Panaroo:  
#  Leverages `Panaroo`, a highly reliable tool for constructing pangenomes while handling spurious genes and noisy datasets.  
# Configurable Parameters:  
#  Supports user-defined options for core gene thresholds, cleaning modes, and computational resources, ensuring scalability for large datasets.

# 3. Pangenome Polishing
# Enhancing Quality with Clarc:  
#  Refines the pangenome by removing redundancies and ensuring accurate, consistent gene presence/absence matrices.  
# Final Output:  
# Provides a polished pangenome dataset, optimized for downstream biological interpretation and analysis.

# =============================================================================================================================

rule copy_gff_files:
    
    input:
        "output/annotation_prokka/{sample}/{sample}.gff"
    
    output:
        "output/input_gff/{sample}.gff"
    
    params:
        destination_dir="output/input_gff"
    
    run:
        import os
        import shutil
        
        # Ensure the destination directory exists
        os.makedirs(params.destination_dir, exist_ok=True)
        
        # Define source and destination paths
        source_path = input[0]
        destination_path = output[0]
        
        # Copy the file
        shutil.copy(source_path, destination_path)
        print(f"Copied: {source_path} -> {destination_path}")
        

rule pangenome_analysis:
    
    input:
        gff= "output/input_gff/*.gff"
    
    output:
        pangenome= "output/pangenome_analysis/"
    
    params:
        outdir="output/pangenome_analysis",
        clean_mode= config["pangenome_analysis"]["clean_mode"],
        core_threshold= config["pangenome_analysis"]["core_threshold"],
        cpus= config["pangenome_analysis"]["cpus"]

    conda:
        "environments/panaroo.yaml"
    
    log:
        "logs/pangenome_analysis/panaroo.log"
    
    benchmark:
        "output/benchmarks/pangenome_analysis/pangenome.panaroo.benchmark.txt"
    
    threads: 16

    shell:
        """
        mkdir -p {params.outdir} && \
        panaroo -i {input.gff} \
        -o {output.pangenome} \
        --clean-mode {params.clean_mode} \
        -a pan \
        -t {params.cpus} \
        --core_threshold {params.core_threshold} \
        --remove-invalid-genes > {log} 2>&1
        """

rule extract_sample_names:
    
    input:
        expand("output/input_gff/{sample}.gff")
    
    output:
        "output/pangenome_analysis/needed_sample_names.txt"
    
    run:
        import os

        input_gff_dir = "output/input_gff"
        output_file = "output/pangenome_analysis/needed_sample_names.txt"

        sample_names = []
        for file in os.listdir(input_gff_dir):
            if file.endswith(".gff"):
                sample_name = os.path.splitext(file)[0]
                sample_names.append(sample_name)

        with open(output_file, "w") as f:
            for sample_name in sorted(sample_names):
                f.write(sample_name + "\n")

        print(f"Sample names written to {output_file}")


rule pangenome_polishing:
    
    input:
        panaroo_dir= "output/pangenome_analysis/"
    
    output:
        clarc= "output/pangenome_analysis/pangenome_polished"
    
    params:
        outdir="output/pangenome_analysis/pangenome_polished"
    
    conda:
        "environments/pangenomics_pipeline.yaml"    
    
    log:
        "logs/pangenome_analysis/clarc.log"
    
    benchmark:
        "output/benchmarks/pangenome_analysis/pangenome.clarc.benchmark.txt"
    
    threads: 16

    shell:
        """
        mkdir -p {params.outdir} && \
        clarc --input_dir {input.panaroo_dir} \
        --output_dir {output.clarc} \
        --panaroo > {log} 2>&1
        """


















