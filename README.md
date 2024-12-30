# Pangenomics Pipeline  
#### Author: Jash Trivedi, University of Central Florida (UCF) 

---  

## **Overview**  

The Pangenomics Pipeline is a highly sophisticated bioinformatics workflow developed for the comprehensive analysis of bacterial pangenomes utilizing multi-strain Whole Genome Sequencing (WGS) and transcriptomics (e.g. RNA-Seq) data. This pipeline integrates a series of advanced algorithms and methodologies to process genomic and transcriptomic data from multiple bacterial strains, with a focus on identifying core and accessory genes, quantifying gene expression levels, and evaluating strain-specific genetic variations. By processing both short and long-read sequencing data, the pipeline creates a hybrid assembly that enhances bacterial genome completeness, which is critical for downstream single nucleotide polymorphism (SNP) analysis and other genomic investigations. 

Structured around Snakemake’s modular framework, the pipeline is highly scalable and customizable. Each step is encapsulated in a separate rule, ensuring efficient execution and ease of maintenance. Parameters are configured centrally in a config.yaml file, allowing for seamless adaptation to different bacterial species and experimental designs.

This pipeline has been successfully applied in the study of *Streptococcus pneumoniae* serotype 3 (ST3), where it facilitated the identification of core and accessory gene sets across several ST3 clinical strains. The analysis provided valuable insights into the pathogen’s virulence potential, evolutionary adaptations, and the genetic factors influencing strain-specific behaviors (clade I vs Clade II ST3). The ability to cross-reference genomic data with transcriptomic profiles allowed for a deeper understanding of the molecular mechanisms underlying bacterial pathogenesis and host adaptation.

---  

## **Key Features**  


### Advanced Capabilities and Advantages  

1. **Comprehensive Analysis of Genetic Diversity**  
   - Enables the identification of core, accessory, and strain-specific genes using cutting-edge tools such as [Panaroo](https://gthlab.au/panaroo/#/gettingstarted/quickstart) and [CLARC](https://github.com/IndraGonz/CLARC). This facilitates a deeper understanding of bacterial evolution and adaptation.  
   - Integrates gene presence/absence data with transcriptomic profiles to uncover functional implications of genetic variations.  

2. **Pan-transcriptomics for Strain-Specific Insights**  
   - Combines pangenomics with transcriptomics to study strain-specific traits at both the genetic and expression levels.  
   - Provides a powerful approach to uncover virulence factors, antibiotic resistance mechanisms, and niche-specific adaptations. This is crucial for understanding strain-specific pathogenicity and host interactions.  

3. **Scalability and Modularity**  
   - Designed to scale from small datasets to large-scale projects involving hundreds of bacterial strains.  
   - Modular structure allows users to execute only the necessary components, making the pipeline highly customizable and efficient.  
   - Centralized configuration in `config.yaml` ensures seamless integration of user-specific parameters.  

4. **Containerized Workflow for Reproducibility**  
   - Supports Docker and Apptainer (formerly Singularity) for containerized execution, ensuring reproducibility and environment consistency across different platforms.  
   - Simplifies deployment on local machines, high-performance computing (HPC) clusters, and cloud-based environments.  

5. **Advanced Usability Features**  
   - Includes benchmarking for resource optimization, DAG visualization for workflow understanding, and the ability to resume interrupted runs with minimal overhead.  
   - Supports dynamic resource allocation to optimize runtime and memory usage based on input dataset size.  

6. **Comprehensive Reporting**  
   - Generates detailed and visually appealing reports using tools like MultiQC, ensuring that users can effectively communicate their findings.  
   - Provides high-quality visualizations for publication-ready outputs.  


---  

## **Pangenomics Pipeline Workflow**  

---  

## **Setup and Usage**  

### **1. Prerequisites**  
- [Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) or [Miniconda](https://docs.anaconda.com/miniconda/)   

### **2. Clone the Repository**  
```bash  
git clone https://github.com/J22160/Pangenomics_Pipeline.git  
```
### **3. Run the setup.sh Script**  
Execute the setup script to install Snakemake and its dependencies:  
```bash  
chmod +x setup.sh  
bash setup.sh  
```
The script performs the following:  
1. Configure a Conda environment for Snakemake.  
2. Install Snakemake and its dependencies.
3. Sets up the CLARCs tool for pangenome polishing. 

**Role of CLARCs in Pangenome Polishing**:

The CLARCs tool is integrated into the pipeline to address the issue of over-splitting accessory genes into multiple clusters of orthologous genes (COGs) during pangenome construction. By reducing over-splitting, CLARCs refines the pangenome, providing more biologically meaningful insights into gene presence/absence patterns and strain-specific adaptations. This is particularly useful for identifying unique accessory genes with potential roles in virulence, antibiotic resistance, or niche adaptation.
 

### **4. Configure the Pipeline**  
Edit the `configs/config.yaml` file to specify:  
- Paths to input data, reference files, and specific parameters for pangenome analysis.  

### **5. Execute the Pipeline**  

The Pangenomics pipeline can be executed on a variety of platforms, including local machines, high-performance computing (HPC) environments, and cloud-based platforms. Below are the instructions for running the pipeline in different environments.

#### **5.1. Perform a Dry Run (Optional but Recommended)**  
Before running the pipeline, it's recommended to perform a dry run to ensure everything is configured correctly without actually executing the tasks. Run:  
```bash  
snakemake --use-conda --cores <number_of_cores> -n  
```
**Why is a dry run useful?**  
- Verifies the correctness of the configuration and paths.  
- Identifies missing or incorrectly specified files.  
- Prevents errors during the actual execution.  

---  

#### **5.2. Running the Pipeline Locally**  
To execute the pipeline on a local machine, use:  
```bash  
snakemake --use-conda  --cores <number_of_cores>  
```
Replace `<number_of_cores>` with the number of CPU cores you wish to allocate.  

---  

#### **5.3. Running on an HPC Cluster**  
For HPC environments, use a job scheduler like Slurm to submit the pipeline as a job. Example Slurm script:

```bash  
#!/bin/bash  
#SBATCH --job-name=pangenomics  
#SBATCH --output=logs/pangenomics_%j.log  
#SBATCH --error=logs/pangenomics_%j.err  
#SBATCH --nodes=1  
#SBATCH --ntasks=16  
#SBATCH --time=24:00:00  
#SBATCH --partition=compute  

module load conda  
conda activate pangenomics_env  

salloc -c 16 snakemake --sdm conda --cores $SLURM_NTASKS  
```
Submit the script using:  
```bash 
chmod +x <script.name>.sh 
sbatch <script_name>.sh  
```
---  

#### **5.4. Running on a Cloud Platform**  

To run your workflow on a cloud-based platform like AWS or Google Cloud, follow these steps:

1. **Set Up a Virtual Machine or Instance**:
   - Create a virtual machine (VM) or instance with the required resources (CPU, memory, and storage) using your cloud provider's console (AWS EC2, Google Cloud Compute Engine).
   - Ensure the instance has sufficient resources based on your workflow's needs.

2. **Install Conda**:
   - On your cloud instance, install Conda if it's not already available. You can follow the instructions from the [Conda documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

3. **Install Pipeline Dependencies**:
   - Set up your environment by installing all necessary dependencies for your Snakemake pipeline. This can be done by creating a Conda environment or using an existing environment. 

4. **Execute the Snakemake Workflow**:
   - After setting up the instance and dependencies, navigate to the directory containing your `Snakefile`.
   - Run the Snakemake workflow with the following command:
     ```bash
     snakemake --use-conda --cores <number_of_cores>
     ```
     Replace `<number_of_cores>` with the number of CPU cores you want to allocate for parallel execution.

5. **Alternative: Use Managed Cloud Services**:
   - For easier management of large-scale workflows, consider using managed services such as AWS Batch or Google Cloud Batch. These services allow for seamless execution of workflows without managing the infrastructure directly.
   - For AWS Batch, you can follow the [AWS Batch documentation](https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html) for setup.
   - For Google Cloud Batch, check the [Google Cloud Batch documentation](https://cloud.google.com/batch).

By following these steps, you can efficiently run your Snakemake workflow on a cloud platform with the required computational resources.

---  

### 5.5. Additional Execution Options

Snakemake offers several advanced execution options to enhance flexibility and control over workflow execution. Below are key features you can leverage:

#### **Resume from an Interrupted Run**
If your workflow is interrupted, you can easily resume from where it stopped using the `--rerun-incomplete` flag. This ensures that only incomplete or failed jobs are re-executed:

```bash
snakemake --use-conda --cores <number_of_cores> --rerun-incomplete
```

#### **Cluster Execution**
To submit jobs dynamically to a cluster, use the `--cluster` option. This allows you to run your workflow in a distributed computing environment, specifying cluster job submission commands (e.g., using `sbatch` for SLURM). You can also include additional cluster-specific options such as partition, time limits, memory, and more:

```bash
snakemake --use-conda --cores <number_of_cores> --cluster "sbatch --partition=compute --time=24:00:00 --mem=8G"
```

#### **Optimizing Cluster Execution with `--jobs`**
To manage the number of simultaneous jobs, the `--jobs` option can be used to limit the maximum number of jobs running at the same time across all nodes. For example, to run a maximum of 50 jobs concurrently:

```bash
snakemake --use-conda --jobs 50 --cluster "sbatch --partition=compute --time=24:00:00"
```

#### **Generate a DAG Visualization**
Visualizing the structure of your pipeline can help identify dependencies and understand workflow execution. Snakemake allows you to generate a Directed Acyclic Graph (DAG) of the workflow. You can convert this into a graphical format using Graphviz (`dot`):

```bash
snakemake --dag | dot -Tpng > dag.png
```

This will create a `dag.png` image representing the tasks and their dependencies.

#### **Monitoring and Logging**
Snakemake provides built-in logging to track workflow execution progress and errors. You can use the `--log` option to specify a log file for capturing output from the entire workflow or individual rules:

```bash
snakemake --use-conda --cores <number_of_cores> --log snakemake.log
```

You can also visualize progress with `--progress` to get a real-time status update in the terminal.

By utilizing these advanced features, you can run and manage your Snakemake workflows more effectively across various environments, improving flexibility, scalability, and efficiency.

---  

## **Benchmarking**  

Each rule in the pipeline includes Snakemake's benchmarking feature, which tracks runtime and resource usage in `.txt` files located in the `output/benchmarks/` directory. This data helps identify potential performance bottlenecks and optimize resource allocation.  

---  
## **Contact Information**  

For questions or support, please contact:  

**Jash Trivedi**  
- Email: jashtrivedi221@gmail.com  
- GitHub: [J22160](https://github.com/J22160)  
- LinkedIn: [Jash Trivedi](https://www.linkedin.com/in/jash-trivedi-25b358191/)  

---  

## **Acknowledgments**  

This pipeline is built upon a collection of powerful open-source tools, thanks to the dedication and innovation of the bioinformatics community. I acknowledge the invaluable contributions of the developers behind Snakemake and other key tools that have made this pipeline efficient and adaptable for diverse genomic analyses.

---  