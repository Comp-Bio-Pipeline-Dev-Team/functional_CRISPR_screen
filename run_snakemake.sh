#!/bin/bash

## can add the --dry-run flag to dry run the workflow

snakemake \
    -R \
    --until \
    render_report \
    -s workflow/snakefile \
    -c 10 \
    --use-conda \
    --config raw_seq_in='raw_crispr_data' \
    sample_id_file='sample_ids.csv' \
    bowtie_mismatches='0' \
    vector_seq_minOverlap='10' \
    vector_seq_error='0.2' \
    crispr_sg_index='reference_data/human_crispr_sgRNA_brunello/human_crispr_sg_brunello'
    ##--report crispr_functional_screen_report.html ##can only run the --report flag after the entire workflow has been run through
