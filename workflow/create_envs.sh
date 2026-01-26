#!/bin/bash

## TO RUN THIS SCRIPT: since you're running it in ubuntu linux and its being funky
## bash workflow/creat_envs.sh

create_my_envs () {
    for path in ${*} ;
        do
            mamba env create -f ${path}
        done
}

env_path_list=("envs/fastqc_env.yml"
"envs/multiqc_env.yml" 
"envs/cutadapt_env.yml" 
"envs/bowtie_env.yml"
"envs/bbmap_env.yml"
"envs/r_env.yml")

echo "installing all conda environments needed for functional CRISPR screen analysis!"
create_my_envs ${env_path_list[*]}