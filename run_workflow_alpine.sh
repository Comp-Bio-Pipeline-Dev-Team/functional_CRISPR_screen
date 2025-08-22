#!/bin/bash 

#SBATCH --nodes=1 # use one node
#SBATCH --time=10:00:00 # 10 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=10 # total processes/threads
#SBATCH --job-name=crispr
#SBATCH --output=crispr_screen_08222025_%J.log
#SBATCH --mem=15G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=your.email@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=crispr_screen_08222025_%J.err

## the python script needs to be verified as an executable! :
## chmod +x functional_CRISPR_screen.py
## chmod +x run_workflow.sh 

module load miniforge
module load singularity/3.6.4

conda activate snakemake

## also need to add path to folder where script lives to my global path like so:
export PATH=/scratch/alpine/${USER}/functional_CRISPR_screen/:$PATH

## will need to add above line to my .bashrc or .bash_profile to keep executable status:
## echo 'export PATH=/Users/apgarm/projects/immuno_micro_bioinformatics/functional_CRISPR_screen/:$PATH' >> ~/.zshrc

# add singularity bind point so can access data outside of the functional_CRISPR_screen directory
export SINGULARITY_BIND="/scratch/alpine/${USER}/data_dir/:/scratch/alpine/${USER}/data_dir/"

# add quarto to your path after you install quarto
export PATH=/projects/${USER}/software/quarto-1.7.33/bin:$PATH

functional_CRISPR_screen.py \
    -c 10 \
    --raw_seq_dir /scratch/alpine/${USER}/data_dir/20250814_LH00407_0160_A235GMTLT3/ \
    --metadata_file /scratch/alpine/${USER}/data_dir/metadata_for_pipeline.csv \
    --bowtie_mismatches 0 \
    --vector_seq_used TTGTGGAAAGGACGAAACACCG \
    --vector_seq_minOverlap 10 \
    --vector_seq_error 0.2 \
    --crispr_sgRNA_index /scratch/alpine/${USER}/data_dir/human_crispr_knockout_pooled_library_brunello.fasta \
    --crispr_sgRNA_index_name brunello \
    --use_singularity True  ## only include this line if you want to run the pipeline in singularity/docker containers
    ## --dry_run True  ## only include this line if you want to dry run the pipeline
