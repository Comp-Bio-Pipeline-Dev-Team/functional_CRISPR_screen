## runs pca analysis on normalized sgRNA/gene counts 

## needed libraries
library(tidyverse)
library(broom)
library(magrittr)
library(edgeR)
library(stats)
library(argparse)

## argparse to link with snakemake
parser <- ArgumentParser()
parser$add_argument("-m",
                    "--metadata",
                    dest = "metadata_fp",
                    help = "Filepath to metadata file in .csv format. 
                    Must have columns named 'sampleid' and 'biological_group'.")
parser$add_argument("-ns",
                    "--norm_sgRNA_counts",
                    dest = "norm_sgRNA_count_fp",
                    help = "Filepath to the cpm normalized sgRNA counts table file as a .tsv.")
parser$add_argument("-ng",
                    "--norm_gene_counts",
                    dest = "norm_gene_count_fp",
                    help = "Filepath to the cpm normalized gene counts table file as a .tsv.")
parser$add_argument("-sgpd",
                    "--sgRNA_PCA_pdf",
                    dest = "sgRNA_pdf_fp",
                    help = "Filepath to the sgRNA count PCA plot as a .pdf.")
parser$add_argument("-sgpn",
                    "--sgRNA_PCA_png",
                    dest = "sgRNA_png_fp",
                    help = "Filepath to the sgRNA count PCA plot as a .png.")
parser$add_argument("-gpd",
                    "--gene_PCA_pdf",
                    dest = "gene_pdf_fp",
                    help = "Filepath to the gene count PCA plot as a .pdf.")
parser$add_argument("-gpn",
                    "--gene_PCA_png",
                    dest = "gene_png_fp",
                    help = "Filepath to the gene count PCA plot as a .png.")
parser$add_argument("-sgpt",
                    "--sgRNA_PCA_table",
                    dest = "sgRNA_pca_table_fp",
                    help = "Filepath to the sgRNA count PCA table as a .tsv.")
parser$add_argument("-gpt",
                    "--gene_PCA_table",
                    dest = "gene_pca_table_fp",
                    help = "Filepath to the gene count PCA table as a .tsv.")
args <- parser$parse_args()

## functions
## takes normalized counts table and conducts a pca analysis
## outputs the pca table and plot
run_pca <- function(norm_df,
                    metadata_df,
                    sample_col,
                    fill_by_col,
                    point_size,
                    point_alpha,
                    brewer_palette,
                    legend_title,
                    plot_title){
  ## running principal component analysis 
  count_pca_results <- prcomp(t(norm_df),
                              center = TRUE,
                              scale. = TRUE)
  
  ## pulling actual PCA values out of the object
  count_pca_table <- count_pca_results$x %>% 
       as_tibble(rownames = sample_col) %>% 
       left_join(metadata_df, by = sample_col)
  
  ## pulling out variance explained for PC1 and PC2
  ## want to pull out the proportion of variance 
  pre_varExp <- summary(count_pca_results)
  pca_varExp <- pre_varExp$importance[2,]
  
  x_lab <- paste0('PC1', '(', as.character(round(pca_varExp[1], digits = 4) * 100), '%)')
  y_lab <- paste0('PC2', '(', as.character(round(pca_varExp[2], digits = 4) * 100), '%)')
  
  ## building actual PCA plot using above data
  pca_plot <- count_pca_table %>% 
    ggplot(aes(x = PC1, y = PC2)) +
    geom_point(aes(fill = .data[[fill_by_col]]), 
               pch = 21, 
               size = point_size, 
               alpha = point_alpha) +
    theme_bw(base_size = 20) +
    scale_fill_brewer(palette = brewer_palette,
                      name = legend_title) +
    theme(legend.position = 'bottom') +
    labs(x = x_lab,
         y = y_lab,
         title = plot_title)
  ## creating list of outputs 
  my_list <- list(PCATable = count_pca_table,
                  PCAPlot = pca_plot)
  return(my_list)
}

## actual analysis
## reading in normalized sgRNA/gene count dataframes
## have to use read.table or else the row names aren't kept
sgRNAnorm_combCounts_df <- read.table(args$norm_sgRNA_count_fp,
                                      check.names = FALSE)
geneNorm_combCounts_df <- read.table(args$norm_gene_count_fp,
                                     check.names = FALSE)
metadata <- read_csv(args$metadata_fp)

## sgRNA PCA analysis
sgRNA_pca_res <- run_pca(norm_df = sgRNAnorm_combCounts_df,
                         metadata_df = metadata,
                         sample_col = 'sampleid',
                         fill_by_col = 'biological_group',
                         point_size = 3,
                         point_alpha = 0.6,
                         brewer_palette = 'Dark2',
                         legend_title = 'Biological Group',
                         plot_title = 'sgRNA Count PCA')

sgRNA_count_pcaTable <- sgRNA_pca_res$PCATable
sgRNA_pca_plot <- sgRNA_pca_res$PCAPlot

## gene PCA analysis
gene_pca_res <- run_pca(norm_df = geneNorm_combCounts_df,
                        metadata_df = metadata,
                        sample_col = 'sampleid',
                        fill_by_col = 'biological_group',
                        point_size = 3,
                        point_alpha = 0.6,
                        brewer_palette = 'Dark2',
                        legend_title = 'Biological Group',
                        plot_title = 'Gene Count PCA')

gene_count_pcaTable <- gene_pca_res$PCATable
gene_pca_plot <- gene_pca_res$PCAPlot

## saving my outputs
## plots - pdf
ggsave(args$sgRNA_pdf_fp,
       plot = sgRNA_pca_plot,
       width = 8,
       height = 6)
ggsave(args$gene_pdf_fp,
       plot = gene_pca_plot,
       width = 8,
       height = 6)

## plots - png (for report generation)
ggsave(args$sgRNA_png_fp,
       plot = sgRNA_pca_plot,
       width = 8,
       height = 6)
ggsave(args$gene_png_fp,
       plot = gene_pca_plot,
       width = 8,
       height = 6)

## PCA result files
write_tsv(sgRNA_count_pcaTable,
          args$sgRNA_pca_table_fp)
write_tsv(gene_count_pcaTable,
          args$gene_pca_table_fp)
