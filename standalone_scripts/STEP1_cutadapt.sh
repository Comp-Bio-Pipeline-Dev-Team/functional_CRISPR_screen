#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=01:00:00 # 1 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=1 # total processes/threads
#SBATCH --job-name=cutadapt
#SBATCH --output=STEP1_cutadapt_08272024_%J.log
#SBATCH --mem=5G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=STEP1_cutadapt_08272024_%J.err

# load modules
module load cutadapt/4.2
module load gnu_parallel/20210322

inBaseDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/20240722_LH00407_0060_A22H2VKLT3/Abbott_Jordan_Transendocytosis_20240709_07112024/"
outDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP1_trimmed_to_guides_cutadapt_outdir/"
gnuParallelCommand="parallel --tag --memfree 1G --delay 0.2 --jobs 5 -u --progress --joblog STEP1_cutadapt_08372024.parallel.out"
#gnuParallelCommand="parallel --tag --memfree 3G --dry-run --delay 0.2 --jobs 10 -u --progress --joblog DRYRUN_STEP1_cutadapt_08272024.parallel.out"



# run to generate fastq prefixes file while maintaining novogene output structure
cd ${inBaseDir}
ls -1 *_R1_001.fastq.gz | sed 's/_R1_001.fastq.gz//' > ${outDir}"fastq_prefixes.txt"

# not trimming for quality as we need the 20bp full region to be intact for guide matching
#5' vector sequence
# TTGTGGAAAGGACGAAACACCG
# trim sequences down to 20 bp since that is the length of the guide
# use only R1

sampleName=( $(cat ${outDir}"fastq_prefixes.txt") )

cd ../../

${gnuParallelCommand} "time cutadapt -g \"TTGTGGAAAGGACGAAACACCG;min_overlap=10;e=0.2\" --length=20 -o ${outDir}{}_trimmed.fastq.gz ${inBaseDir}{}_R1_001.fastq.gz 1>{}_cutadapt.log 2>{}_cutadapt.err" ::: ${sampleName[@]}
