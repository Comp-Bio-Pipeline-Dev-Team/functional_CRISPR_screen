#!/bin/bash

#SBATCH --nodes=1 # use one node
#SBATCH --time=10:00:00 #10:00:00 10 hours
#SBATCH --account=amc-general # normal, amc, long, mem (use mem when using the amem partition)
#SBATCH --partition=amilan # amilian, ami100, aa100, amem, amc
#SBATCH --qos=normal
#SBATCH --ntasks=10 #total processes/threads
#SBATCH --job-name=align
#SBATCH --output=STEP2_bowtie1_alignment_09022024_%J.log
#SBATCH --mem=50G #suffix K,M,G,T can be used with default to M
#SBATCH --mail-user=tonya.brunetti@cuanschutz.edu
#SBATCH --mail-type=END
#SBATCH --error=STEP2_bowtie1_alignment_09022024_%J.err

module load samtools/1.16.1
module load gnu_parallel/20210322

bowtie1="/projects/$USER/software/bowtie-1.3.1-linux-x86_64/bowtie"
bowtie1_index="/projects/$USER/reference_data/human_crispr_sgRNA_brunello/human_crispr_sg_brunello"
outDir='/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP2_bowtie1_alignment_outdir/'
inDir='/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP1_trimmed_to_guides_cutadapt_outdir/'
unalignedOutDir='/scratch/alpine/brunetti@xsede.org/crispr_screen_brunello_library_08262024/STEP2_bowtie1_alignment_outdir/unaligned/'
mismatches=(0 1 2)
currentDir=$(pwd)

cd ${inDir}
fastqs_to_process=$( ls -1 *_trimmed.fastq.gz|sed 's/_trimmed.fastq.gz//g' )

cd ${currentDir}

gnuParallelCommand="parallel --tag --memfree 3G --delay 0.2 --jobs 5 -u --progress --joblog STEP2_bowtie1_09022024.parallel.out"
#gnuParallelCommand="parallel --tag --memfree 3G --dry-run --delay 0.2 --jobs 4 -u --progress --joblog DRYRUN_STEP2_bowtie1_09022024.parallel.out"


# Alignment
# set trimming of 5' and 3' to 0 since data was already trimmed to sgRNA regions
# Allowing x number of mismatches (-v)
# --best --strata ensures only the best alignment is returned
# https://horizondiscovery.com/-/media/Files/Horizon/resources/Protocols/decode-pooled-bioinfomatic-analysis-protocol.pdf

#${gnuParallelCommand} "(${bowtie1} -p 4 ${bowtie1_index} ${inDir}{1}_trimmed.fastq.gz -S --no-unal --trim5 0 --trim3 0 --best --strata -m 1 --un ${unalignedOutDir}{1}_mismatches_allowed_{2}_unaligned -v {2} | samtools view -bS -o ${outDir}{1}_mismatches_allowed_{2}.bam -) 1>${outDir}{1}_mismatches_allowed_{2}.log 2>${outDir}{1}_mismatches_allowed_{2}.err" ::: ${fastqs_to_process[@]} ::: ${mismatches[@]}

${gnuParallelCommand} "(${bowtie1} -p 4 ${bowtie1_index} ${inDir}{1}_trimmed.fastq.gz -S --no-unal --trim5 0 --trim3 0 --best --strata -m 1 --un ${unalignedOutDir}{1}_mismatches_allowed_{2}_unaligned -v {2} > ${outDir}{1}_mismatches_allowed_{2}.sam) 1>${outDir}{1}_mismatches_allowed_{2}.log 2>${outDir}{1}_mismatches_allowed_{2}.err" ::: ${fastqs_to_process[@]} ::: ${mismatches[@]}
