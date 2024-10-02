#!/bin/bash

snakemake \
    -s workflow/snakefile \
    -c 10 \
    --use-conda \
    --config raw_seq_in='test_dir' \
    sample_id_file='sample_ids.csv' \
    crispr_sg_index='reference_data/human_crispr_sgRNA_brunello/human_crispr_sg_brunello'
