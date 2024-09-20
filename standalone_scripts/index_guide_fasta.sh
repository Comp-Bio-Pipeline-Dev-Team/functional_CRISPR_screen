#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=01:00:00 # 1 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=2 # total processes/threads
#SBATCH --job-name=index
#SBATCH --output=bowtie1_index_sg_guide_fasta_brunello_08272024_%J.log
#SBATCH --mem=7G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=bowtie1_index_sg_guide_fasta_brunello_08272024_%J.err

bowtie1="/projects/brunetti@xsede.org/software/bowtie-1.3.1-linux-x86_64/bowtie-build"
fasta="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/human_crispr_knockout_pooled_library_brunello.fasta"
outDir="/projects/brunetti@xsede.org/reference_data/human_crispr_sgRNA_brunello/"

${bowtie1} --threads 2  ${fasta} ${outDir}human_crispr_sg_brunello
