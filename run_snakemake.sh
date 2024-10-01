#!/bin/bash

snakemake \
    --dry-run \
    --use-conda \
    --config raw_seq_in='test_dir' sample_id_file='sample_ids.csv'
