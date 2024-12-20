#!/bin/bash

## can add the --dry-run flag to dry run the workflow

snakemake \
    ##-R \ i use these top lines to only run the report generating rule so i can test it 
    ##--until \
    ##render_report \
    -s workflow/snakefile \
    -c 10 \
    --use-conda \
    --config raw_seq_in='raw_crispr_data' \
    metadata_file='metadata.csv' \
    bowtie_mismatches='0' \
    vector_seq_minOverlap='10' \
    vector_seq_error='0.2' \
    crispr_sg_index='reference_data/human_crispr_sgRNA_brunello/human_crispr_sg_brunello' ## this is where my sgRNA index lives
