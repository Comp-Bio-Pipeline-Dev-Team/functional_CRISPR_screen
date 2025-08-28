#!/bin/bash

## the python script needs to be verified as an executable! :
## chmod +x functional_CRISPR_screen.py
## chmod +x run_workflow.sh

## also need to add path to folder where script lives to my global path like so:
## export PATH=/Users/apgarm/projects/immuno_micro_bioinformatics/functional_CRISPR_screen/:$PATH

## will need to add above line to my .bashrc or .bash_profile to keep executable status:
## echo 'export PATH=/Users/apgarm/projects/immuno_micro_bioinformatics/functional_CRISPR_screen/:$PATH' >> ~/.zshrc

functional_CRISPR_screen.py \
    -c 1 \
    --raw_seq_dir 'directory_with_raw_seqs' \
    --metadata_file 'path/to/metadata.csv' \
    --out_dir_name 'my_project_name' \
    --bowtie_mismatches 0 \
    --vector_seq_used 'TTGTGGAAAGGACGAAACACCG' \
    --vector_seq_minOverlap 10 \
    --vector_seq_error 0.2 \
    --crispr_sgRNA_index "path/to/sgRNA_index.fasta" \
    --crispr_sgRNA_index_name "name_of_sgRNA_index" \
    --latency_wait 60
    ## --use_singularity \ ## only include this line if you want to run the pipeline in singularity/docker containers
    ## --dry_run  ## only include this line if you want to dry run the pipeline
