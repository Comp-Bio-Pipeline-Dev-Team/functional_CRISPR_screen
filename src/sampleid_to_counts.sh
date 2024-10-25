#!/bin/bash

## attempting to append a column to each counts text file with the associated sampleid
##cd ../crispr_screen_out/count_output/
##file_list=(*_counts.txt)
##
##for f in ${file_list[*]};
##    do 
##        awk 'NR == 1 {print $0 "\tsampleid"; next;}{print $0 "\t" FILENAME;}' ${f} > proc_${f};
##    done
##
#### concatonates the files and only includes the header for the first one
##awk 'NR==FNR||FNR>1' proc_*_counts.txt >> allSample_counts_test.tsv



## second try
## need to check this 
cd ../backup_files/
file_list=( $(ls *counts.txt | sed 's/_counts.txt//g') )

for f in ${file_list[*]};
    do 
        awk 'NR == 1 {print $0 "\tsampleid"; next;}{print $0 "\t" FILENAME;}' ${f}_counts.txt > ${f}_counts_final.txt;
    done


awk 'NR==FNR||FNR>1' *_counts_final.txt >> test.tsv

