#!/bin/bash

## putting together the end stats table for the report 
sampleid="transE-High_S47_L005"
echo ${sampleid}

## 1 - total number of reads sequenced
## number of lines in the raw fastq file divided by four 
total_num_reads=$(awk 'END{print NR/4}' ../raw_crispr_data/transE-High_S47_L005_R1_001.fastq.gz)
echo ${total_num_reads}

## 2 - reads containing a vector 
## number of lines in cutadapt TRIMMED fastq divided by four
reads_with_vector=$(awk 'END{print NR/4}' ../crispr_screen_out/cutadapt_outputs/transE-High_S47_L005_trimmed.fastq.gz)
echo ${reads_with_vector}

## 3 - reads with no vector detected
## number of lines in cutadapt UNTRIMMED fastq file divided by four
reads_with_noVector=$(awk 'END{print NR/4}' ../crispr_screen_out/cutadapt_outputs/transE-High_S47_L005_untrimmed.fastq.gz)
echo ${reads_with_noVector}

## 4 - reads mapping to a sgRNA 
## pull from bowtie_aligned logs 
reads_mapped_sgRNA=$(grep "reads with at least one alignment:" ../crispr_screen_out/bowtie_aligned/transE-High_S47_L005_mismatches_allowed.log | sed 's/# reads with at least one alignment: //g')
echo ${reads_mapped_sgRNA}

## 5 - total sgRNAs represented
## total number of unique guides with at least one read count detected (from counts file) - this one is right!
total_sgRNA=$(awk '$7 != 0 {print $7}' ../crispr_screen_out/count_output/transE-High_S47_L005_counts_final.txt | wc -l)
echo ${total_sgRNA}

## 6 - total sgRNAs represented with more than 10 reads 
## idk why this awk command isn't working (i was referencing the wrong column whoops)
sgRNA_moreThan_10=$(awk -F "\t" '{ if ($7 >= 10) {print $7} }' ../crispr_screen_out/count_output/transE-High_S47_L005_counts_final.txt | wc -l)
echo ${sgRNA_moreThan_10}

## tab variable 
tab=$(printf '\t')
## putting all variables together 
##echo ${sampleid}${tab}${total_num_reads}${tab}${reads_with_vector}${tab}${reads_with_noVector}${tab}${reads_mapped_sgRNA}${tab}${total_sgRNA}${tab}${sgRNA_moreThan_10} > ${sampleid}_test.tsv

echo "$sampleid$tab$total_num_reads$tab$reads_with_vector$tab$reads_with_noVector$tab$reads_mapped_sgRNA$tab$total_sgRNA$tab$sgRNA_moreThan_10" > ${sampleid}_test.tsv


