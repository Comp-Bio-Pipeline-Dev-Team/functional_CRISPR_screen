#!/bin/bash

## attempting to append a column to each counts text file with the associated sampleid
 
cd ../backup_files/
file_list=( $(ls *counts.txt | sed 's/_counts.txt//g') )

for f in ${file_list[*]};
    do 
        awk 'NR == 1 {print $0 "\tsampleid"; next;}{print $0 "\t" FILENAME;}' ${f}_counts.txt > ${f}_counts_final.txt;
    done


awk 'NR==FNR||FNR>1' *_counts_final.txt >> test.tsv

