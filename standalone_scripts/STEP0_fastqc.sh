#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=00:30:00 # 30 min
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=4 # total processes/threads
#SBATCH --job-name=fastqc
#SBATCH --output=STEP0_fastqc_crispr_screen_08262024_%J.log
#SBATCH --mem=20G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=STEP0_fastqc_crispr_screen_08262024_%J.err

module load fastqc/0.11.9
module load multiqc/1.14

inDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/20240722_LH00407_0060_A22H2VKLT3/Abbott_Jordan_Transendocytosis_20240709_07112024/"
outDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP0_fastqc_outdir/"

echo "Running fastqc"

cd ${inDir}
time fastqc *.fastq.gz -o ${outDir} --threads 8

wait

cd ${outDir}

echo "Running multiqc"
time multiqc -o ${outDir} --filename STEP0_fastqc_crispr_screen_08262024.html .
