#!/usr/bin/env python3

import subprocess
import argparse
import os
from importlib.resources import files
import yaml

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--cores",
                        help="Number of cores that Snakemake will use",
                        default=10)
    parser.add_argument("--raw_seq_dir",
                        help="The filepath to the directory that contains your FASTQ files")
    parser.add_argument("--metadata_file",
                        help="The filepath to your metadata .csv file. \
                              Your metadata file must contain at least two columns, \
                              a 'sampleid' column and a 'biological_group' column")
    parser.add_argument("--bowtie_mismatches",
                        help="The number of mismatches allowed when aligning vector sequences to sgRNA",
                        default=0)
    parser.add_argument("--vector_seq_used",
                        help="The 20 base pair vector sequence used to infect the cells in wet lab experiments")
    parser.add_argument("--vector_seq_minOverlap",
                        help="The minimum number of vector sequence base pair overlap when trimming them",
                        default=10)
    parser.add_argument("--vector_seq_error",
                        help="The error rate allowed when aligning vector sequences to sgRNA",
                        default=0.2)
    parser.add_argument("--crispr_sgRNA_index",
                        help="The sgRNA index library that samples were prepped with")
    parser.add_argument("--crispr_sgRNA_index_name",
                        help="The name of the sgRNA index library that samples were prepped with") 
    parser.add_argument("--use_conda",
                        help="If this parameter is set to True, the workflow will run using conda \
                              environments instead of singularity",
                        default=None)
    parser.add_argument("--dry_run",
                        help="If this parameter is set to True, you can practice running the workflow without \
                              actually starting it",
                        default=None)
    return parser.parse_args()


## these two functions are not working to get me the desired file paths and idk what's going on 
def get_snake_path():
    return str(files("functional_CRISPR_screen").joinpath("workflow/snakefile"))


def get_config_path():
    return str(files("functional_CRISPR_screen").joinpath("workflow/config/config.yml"))


def create_config_file(config_path,
                       args):
    config_params = {"raw_seq_in": args.raw_seq_dir,
                     "metadata_file": args.metadata_file,
                     "bowtie_mismatches": args.bowtie_mismatches,
                     "vector_seq_used": args.vector_seq_used,
                     "vector_seq_minOverlap": args.vector_seq_minOverlap,
                     "vector_seq_error": args.vector_seq_error,
                     "crispr_sgRNA_index": args.crispr_sgRNA_index,
                     "crispr_sgRNA_index_name": args.crispr_sgRNA_index_name}
    
    with open(config_path, 'w') as outfile:
        yaml.dump(config_params, outfile, default_flow_style=False, sort_keys=False)


def assemble_snake_command(snake_path,
                           config_path,
                           args):

    snake_command = ["snakemake",
                    "-s", snake_path,
                    "--configfile", config_path,
                    "-c", str(args.cores)]
    
    if args.use_conda is not None:
        snake_command.append("--use-conda")
    else:
        snake_command.append("--use-singularity")
    
    if args.dry_run is not None:
        snake_command.append("--dry-run")
    
    return snake_command


def main():
    args = get_args()

    where_snake = get_snake_path()
    where_config = get_config_path()

    short_config_path = "workflow/config/config.yml"
    
    create_config_file(short_config_path,
                       args)
    
    command = assemble_snake_command(where_snake,
                                     where_config,
                                     args)
    complete = subprocess.run(command)


if __name__=="__main__":
    main()
