#!/bin/bash

## will need to zcat all gzipped files for accurate counts!!
## have to use gzcat for my system, may just be zcat for linux distributions

## putting together columns for summary stat table 
printf "sampleid\tnum_reads_seq\treads_with_vector\treads_with_noVector\treads_mapped_sgRNA\treads_notMapped_sgRNA\treads_suppMapped_sgRNA\ttotal_sgRNA\tsgRNA_moreThan_10\n" > ../report/summary_stats/stat_table_cols.tsv

##percent sign for below
percent=$(printf '%%')
## parentheses to put around percent
left_paren=$(printf '(')
right_paren=$(printf ')')

## putting together the end stats table for the report 
sampleid="transE-High_S47_L005"
echo ${sampleid}

## 1 - total number of reads sequenced
## number of lines in the raw fastq file divided by four 
##zcat file | awk...{print NR/4} - can do it without the END 
total_num_reads=$(gzcat ../raw_crispr_data/transE-High_S47_L005_R1_001.fastq.gz | awk 'END{print NR/4}')
echo ${total_num_reads}

## 2 - reads containing a vector 
## number of lines in cutadapt TRIMMED fastq divided by four
reads_with_vector_num=$(gzcat ../crispr_screen_out/cutadapt_outputs/transE-High_S47_L005_trimmed.fastq.gz | awk 'END{print NR/4}')
reads_with_vector_perc=$(echo "($reads_with_vector_num/$total_num_reads)*100" | bc -l | xargs printf "%.2f")
reads_with_vector=$(echo $reads_with_vector_num $left_paren$reads_with_vector_perc$percent$right_paren)
echo ${reads_with_vector}

## 3 - reads with no vector detected
## number of lines in cutadapt UNTRIMMED fastq file divided by four
## this is a really small decimal so scale=4 instead of 2 so its not just zero 
reads_with_noVector_num=$(gzcat ../crispr_screen_out/cutadapt_outputs/transE-High_S47_L005_untrimmed.fastq.gz | awk 'END{print NR/4}')
reads_with_noVector_perc=$(echo "($reads_with_noVector_num/$total_num_reads)*100" | bc -l | xargs printf "%.2f")
reads_with_noVector=$(echo $reads_with_noVector_num $left_paren$reads_with_noVector_perc$percent$right_paren)
echo ${reads_with_noVector}

## 4 - reads mapping to a sgRNA 
## pulled from line 2 of the bowtie_aligned logs 
reads_mapped_sgRNA=$(grep "reads with at least one alignment:" ../crispr_screen_out/bowtie_aligned/transE-High_S47_L005_mismatches_allowed.log | sed 's/# reads with at least one alignment: //g')
echo ${reads_mapped_sgRNA}

## 5 - reads that failed to align (map) in bowtie 
## pulled from line 3 of the bowtie_aligned logs
reads_notMapped_sgRNA=$(grep "reads that failed to align:" ../crispr_screen_out/bowtie_aligned/transE-High_S47_L005_mismatches_allowed.log | sed 's/# reads that failed to align: //g')
echo ${reads_notMapped_sgRNA}

## 6 - reads with alignments suppressed due to -m
## pulled from line 4 of the bowtie_aligned logs
reads_suppMapped_sgRNA=$(grep "reads with alignments suppressed due to -m:" ../crispr_screen_out/bowtie_aligned/transE-High_S47_L005_mismatches_allowed.log | sed 's/# reads with alignments suppressed due to -m: //g')
echo ${reads_suppMapped_sgRNA}

## calculating number of sgRNAs in library
library_sgRNAs=$(grep "^>" ../reference_data/int/human_crispr_knockout_pooled_library_brunello.fasta | wc -l)

## 7 - total sgRNAs represented
## total number of unique guides with at least one read count detected (from counts file) - this one is right!
total_sgRNA_num=$(awk '$7 != 0 {print $7}' ../crispr_screen_out/count_output/transE-High_S47_L005_counts_final.txt | wc -l)
total_sgRNA_perc=$(echo "($total_sgRNA_num/$library_sgRNAs)*100" | bc -l | xargs printf "%.2f")
total_sgRNA=$(echo $total_sgRNA_num $left_paren$total_sgRNA_perc$percent$right_paren)
echo ${total_sgRNA}

## 8 - total sgRNAs represented with more than 10 reads 
## idk why this awk command isn't working (i was referencing the wrong column whoops)
sgRNA_moreThan_10_num=$(awk '$7 >= 10 {print $7}' ../crispr_screen_out/count_output/transE-High_S47_L005_counts_final.txt | wc -l)
sgRNA_moreThan_10_perc=$(echo "($sgRNA_moreThan_10_num/$library_sgRNAs)*100" | bc -l | xargs printf "%.2f")
sgRNA_moreThan_10=$(echo $sgRNA_moreThan_10_num $left_paren$sgRNA_moreThan_10_perc$percent$right_paren)
echo ${sgRNA_moreThan_10}

## tab variable 
tab=$(printf '\t')

## putting all variables together 
echo "$sampleid$tab$total_num_reads$tab$reads_with_vector$tab$reads_with_noVector$tab$reads_mapped_sgRNA$tab$reads_notMapped_sgRNA$tab$reads_suppMapped_sgRNA$tab$total_sgRNA$tab$sgRNA_moreThan_10" > ${sampleid}_test.tsv


