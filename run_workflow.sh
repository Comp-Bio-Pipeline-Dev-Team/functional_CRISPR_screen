#!/bin/bash

functional_CRISPR_screen.py \
    -c 10 \
    --raw_seq_dir 'raw_crispr_data' \
    --metadata_file 'metadata.csv' \
    --bowtie_mismatches 0 \
    --vector_seq_used 'TTGTGGAAAGGACGAAACACCG' \
    --vector_seq_minOverlap 10 \
    --vector_seq_error 0.2 \
    --crispr_sgRNA_index 'reference_data/human_crispr_sgRNA_brunello/human_crispr_sg_brunello' \
    --use_conda True \
    --dry_run True