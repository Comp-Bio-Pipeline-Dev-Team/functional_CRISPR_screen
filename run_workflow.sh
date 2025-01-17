#!/bin/bash 

## the python script needs to be verified as an executable! :
## chmod +x functional_CRISPR_screen.py

## also need to add path to folder where script lives to my global path like so:
## export PATH=/Users/apgarm/projects/immuno_micro_bioinformatics/functional_CRISPR_screen/:$PATH

## will need to add above line to my .bashrc or .bash_profile to keep executable status:
## echo 'export PATH=/Users/apgarm/projects/immuno_micro_bioinformatics/functional_CRISPR_screen/:$PATH' >> ~/.zshrc

functional_CRISPR_screen.py \
    -c 10 \
    --raw_seq_dir 'raw_crispr_data' \
    --metadata_file 'metadata.csv' \
    --bowtie_mismatches 0 \
    --vector_seq_used 'TTGTGGAAAGGACGAAACACCG' \
    --vector_seq_minOverlap 10 \
    --vector_seq_error 0.2 \
    --crispr_sgRNA_index "human_brunello" \
    --use_conda True \
    --dry_run True