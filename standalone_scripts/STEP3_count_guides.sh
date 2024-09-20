#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=02:00:00 # 30 min
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=4 # total processes/threads
#SBATCH --job-name=counts
#SBATCH --output=STEP3_count_guides_09072024_%J.log
#SBATCH --mem=20G # suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=STEP3_counts_guides_09072024_%J.err

module load gnu_parallel/20210322

bbmap_pileup="/projects/brunetti@xsede.org/software/bbmap/pileup.sh"
inDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP2_bowtie1_alignment_outdir/"
outDir="/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP3_count_outdir/"
gnuParallelCommand="parallel --tag --memfree 5G --delay 0.2 --jobs 5 -u --progress --joblog STEP3_count_guides_09072024.parallel.out"

cd ${inDir}

samples=( $(ls -1 *0.sam | sed 's/.sam//g') )

# Counting with BBMAP
${gnuParallelCommand} "time ${bbmap_pileup} in=${inDir}{}.sam out=${outDir}{}_counts.txt 1>${outDir}{}_bbpileup.log 2>${outDir}{}_bbpileup.err" ::: ${samples[@]}
