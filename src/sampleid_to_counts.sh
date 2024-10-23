#!/bin/bash

## attempting to append a column to each counts text file with the associated sampleid
cd ../crispr_screen_out/count_output/test_files
file_list=(*_counts.txt)

for f in ${file_list[*]};
    do 
        awk 'NR == 1 {print $0 "\tsampleid"; next;}{print $0 "\t" FILENAME;}' ${f} > proc_${f};
    done

## concatonates the files and only includes the header for the first one
awk 'NR==FNR||FNR>1' proc_*_counts.txt >> allSample_counts_test.tsv

