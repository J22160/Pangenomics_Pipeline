#============================================ multiqc.smk ======================================================

# Overview:  
# This Snakemake rule is responsible for generating a comprehensive MultiQC report to consolidate the quality control metrics 
# from multiple FastQC reports. MultiQC is a widely-used tool in bioinformatics for summarizing and visualizing QC results 
# across multiple samples in a single, easily interpretable HTML report. This step provides a final summary of the quality 
# assessment after preprocessing, ensuring that all trimmed reads meet the required quality standards before proceeding 
# with downstream analysis.

#=====================================================================================================================

# rule for generating multiqc report
rule multiqc_report:

    input:
        trimmed_qc= "output/clean_short_reads_fastqc/"
        
    output:
        report="output/multiqc/multiqc_report.html"
    
    log:
        "logs/multiqc/multiqc_report.log"
    
    conda:
        "environments/multiqc.yaml"  
    
    shell:
        """
        multiqc {input.trimmed_qc} -o {output.report} > {log} 2>&1
        """
