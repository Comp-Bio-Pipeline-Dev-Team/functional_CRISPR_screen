#!/bin/bash

## TO RUN THIS SCRIPT: since you're running it in ubuntu linux and its being funky
## bash workflow/creat_envs.sh

create_my_envs () {
    for path in ${*} ;
        do
            mamba env create -f ${path}
        done
}

env_path_list=("workflow/envs/fastqc_env.yml"
"workflow/envs/multiqc_env.yml" 
"workflow/envs/cutadapt_env.yml" 
"workflow/envs/bowtie_env.yml"
"workflow/envs/bbmap_env.yml"
"workflow/envs/r_env.yml")

echo "installing all conda environments needed for functional CRISPR screen analysis!"
create_my_envs ${env_path_list[*]}