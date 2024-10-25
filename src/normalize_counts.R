## will normalize combined counts table for further analysis

## needed libraries 
library(tidyverse)
library(broom)
library(magrittr)
library(edgeR)
library(stats)
library(argparse)

## argparse to link with snakemake
parser <- ArgumentParser()
parser$add_argument("-c",
                    "--comb_count_table",
                    dest = "comb_table_fp",
                    help = "Filepath to combined counts table file in .tsv format.")
parser$add_argument("-l",
                    "--comb_countLong_out",
                    dest = "comb_countLong_fp",
                    help = "Filepath to long format combined counts table file as a .tsv.")
parser$add_argument("-sw",
                    "--sgRNA_counts_wide",
                    dest = "sgRNA_counts_wide_fp",
                    help = "Filepath to wide format sgRNA counts table file as a .tsv.")
parser$add_argument("-ns",
                    "--norm_sgRNA_counts",
                    dest = "norm_sgRNA_count_fp",
                    help = "Filepath to the cpm normalized sgRNA counts table file as a .tsv.")
parser$add_argument("-gw",
                    "--gene_counts_wide",
                    dest = "gene_counts_wide_fp",
                    help = "Filepath to wide format gene counts table file as a .tsv.")
parser$add_argument("-ng",
                    "--norm_gene_counts",
                    dest = "norm_gene_count_fp",
                    help = "Filepath to the cpm normalized gene counts table file as a .tsv.")

args <- parser$parse_args()

## functions
## takes the combined counts table from long to wide format and normalizes it by cpm 
## we only need the plus read columns !!
normalize_table <- function(comb_table,
                            id_col){
  
  if (id_col == 'gene_id') {
    comb_table <- comb_table %>% 
      group_by(gene_id, sampleid) %>% 
      summarise(reads_per_gene = sum(Plus_reads))
    
    reads_col <- 'reads_per_gene'
  } else {
    reads_col <- 'Plus_reads'
  }
  
  ## selected the Plus_reads column
  ## taking the tibble from long to wide format w the sampleids as the columns
  comb_table_wide_df <- comb_table %>% 
    select(.data[[id_col]], .data[[reads_col]], sampleid) %>% 
    spread(sampleid, .data[[reads_col]]) %>% 
    remove_rownames() %>% 
    column_to_rownames(var = id_col)
  
  comb_table_wide_df["sum_cols"] <- rowSums(comb_table_wide_df)
  comb_table_wide_df <- subset(comb_table_wide_df,
                               sum_cols != 0,
                               select = -sum_cols)
  
  ## cpm won't work if the data frame contains any categorical values 
  norm_combTable_df <- edgeR::cpm(comb_table_wide_df)
  norm_combTable_df <- as.data.frame(norm_combTable_df)
  
  ## creating a list of outputs
  my_list <- list(NonNormTable = comb_table_wide_df,
                  NormTable = norm_combTable_df)
  return(my_list)
}

## actual analysis
## mild data wrangling
comb_table <- read_tsv(args$comb_table_fp)
comb_table$sampleid <- gsub("*_counts.txt", "", comb_table$sampleid)

comb_counts <- comb_table %>% 
  rename(sgRNA_id = `#ID`) %>% 
  select(sgRNA_id, Plus_reads, sampleid) %>% 
  separate_wider_delim(cols = sgRNA_id,
                       delim = "_",
                       names = c("gene_id"),
                       cols_remove = FALSE,
                       too_many = 'drop')

## normalization for sgRNA ids
sgCount_table_out <- normalize_table(comb_table = comb_counts,
                                     id_col = 'sgRNA_id')

sgRNA_combCounts_wide_df <- sgCount_table_out$NonNormTable
sgRNAnorm_combCounts_df <- sgCount_table_out$NormTable

## normalization for gene ids
geneCount_table_out <- normalize_table(comb_table = comb_counts,
                                       id_col = 'gene_id')

gene_combCounts_wide_df <- geneCount_table_out$NonNormTable
geneNorm_combCounts_df <- geneCount_table_out$NormTable

## saving my outputs
## combined counts table in long format
write_tsv(comb_counts,
          args$comb_countLong_fp)

## sgRNA ids
## have to use write.table() to keep rownames in the .tsv files since write_tsv doesn't include them 
## combined counts table in wide format
write.table(sgRNA_combCounts_wide_df,
            args$sgRNA_counts_wide_fp,
            sep = "\t",
            row.names = TRUE)

## normalized combined counts table in wide format
write.table(sgRNAnorm_combCounts_df,
            args$norm_sgRNA_count_fp,
            sep = "\t",
            row.names = TRUE)

## gene ids
## combined counts table in wide format
write.table(gene_combCounts_wide_df,
            args$gene_counts_wide_fp,
            sep = "\t",
            row.names = TRUE)

## normalized combined counts table in wide format
write.table(geneNorm_combCounts_df,
            args$norm_gene_count_fp,
            sep = "\t",
            row.names = TRUE)