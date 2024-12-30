#======================================== assembly_annotation.smk =====================================================

# Overview:  
# This Snakemake rule performs genome annotation on assembled sequences using `Prokka`, a comprehensive tool for annotating 
# bacterial, archaeal, and viral genomes. Genome annotation involves identifying coding regions, assigning functional 
# information to genes, and generating outputs in standard formats like GFF, GenBank, and FASTA.  
# Prokka is optimized for speed and accuracy, making it an excellent choice for automated annotation workflows.  

# Key Features of the Rule:  
# - Input: The genome assembly file (FASTA format) generated from the hybrid assembly step.  
# - Output: Annotation files, specifically in GFF format, which serve as input for downstream comparative genomics and 
#   functional analyses.  

#=====================================================================================================================

# rule to perform annotations for genome assembly 
rule prokka_annotation:
    input:
        fasta= "output/hybrid_assembly/{sample}/{sample}.fasta"
    output:
        annotation= "output/annotation_prokka/{sample}/{sample}.gff"
    
    params:
        outdir="output/annotation_prokka/{sample}",
        prefix="{sample}",
        genus= config["prokka_annotation"]["genus"],
        species= config["prokka_annotation"]["species"],
        cpus= config["prokka_annotation"]["cpus"]

    conda:
        "environments/prokka.yaml"
    
    log:
        "logs/assembly_prokka/{sample}_prokka.log"
    
    benchmark:
        "output/benchmarks/annotaiton_prokka/{sample}.annotation.benchmark.txt"
    
    threads: 16

    shell:
        """
        mkdir -p {params.outdir} && \
        prokka --genus {params.genus} \
            --species {params.species} \
            --usegenus \
            --outdir {params.outdir} \
            --prefix {params.prefix} \
            --cpus {params.cpus} \
            --force \
            --compliant \
            --locustag \
            {input.fasta} > {log} 2>&1
        """