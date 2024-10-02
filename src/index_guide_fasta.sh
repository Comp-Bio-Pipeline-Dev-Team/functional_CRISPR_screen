#!/bin/bash

## indexing the guide .fasta file
bowtie-build \
    --threads 2 \
    "..int/human_crispr_knockout_pooled_library_brunello.fasta" \
    "../human_crispr_sgRNA_brunello/human_crispr_sg_brunello"