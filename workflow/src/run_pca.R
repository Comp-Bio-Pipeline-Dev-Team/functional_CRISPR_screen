## runs pca analysis on normalized sgRNA/gene counts 

#### needed libraries ####
library(tidyverse)
library(broom)
library(magrittr)
library(edgeR)
library(stats)
library(argparse)

#### argparse to link with snakemake ####
parser <- ArgumentParser()
parser$add_argument("-m",
                    "--metadata",
                    dest = "metadata_fp",
                    help = "Filepath to metadata file in .csv format. 
                    Must have columns named 'sampleid' and 'biological_group'.")
parser$add_argument("--norm_sgRNA_counts",
                    dest = "norm_sgRNA_count_fp",
                    help = "Filepath to the cpm normalized sgRNA counts table file as a .tsv.")
parser$add_argument("--norm_gene_counts",
                    dest = "norm_gene_count_fp",
                    help = "Filepath to the cpm normalized gene counts table file as a .tsv.")
parser$add_argument("--bioG_sgRNA_PCA_pdf",
                    dest = "bioGroup_sgRNA_pdf_fp",
                    help = "Filepath to the sgRNA count PCA biological group plot as a .pdf.")
parser$add_argument("--bioG_sgRNA_PCA_png",
                    dest = "bioGroup_sgRNA_png_fp",
                    help = "Filepath to the sgRNA count PCA biological group plot as a .png.")
parser$add_argument("--batch_sgRNA_PCA_pdf",
                    dest = "batch_sgRNA_pdf_fp",
                    help = "Filepath to the sgRNA count PCA batch plot as a .pdf.")
parser$add_argument("--batch_sgRNA_PCA_png",
                    dest = "batch_sgRNA_png_fp",
                    help = "Filepath to the sgRNA count PCA batch plot as a .png.")
parser$add_argument("--bioG_gene_PCA_pdf",
                    dest = "bioGroup_gene_pdf_fp",
                    help = "Filepath to the gene count PCA biological group plot as a .pdf.")
parser$add_argument("--bioG_gene_PCA_png",
                    dest = "bioGroup_gene_png_fp",
                    help = "Filepath to the gene count PCA biological group plot as a .png.")
parser$add_argument("--batch_gene_PCA_pdf",
                    dest = "batch_gene_pdf_fp",
                    help = "Filepath to the gene count PCA batch plot as a .pdf.")
parser$add_argument("--batch_gene_PCA_png",
                    dest = "batch_gene_png_fp",
                    help = "Filepath to the gene count PCA batch plot as a .png.")
parser$add_argument("--sgRNA_PCA_table",
                    dest = "sgRNA_pca_table_fp",
                    help = "Filepath to the sgRNA count PCA table as a .tsv.")
parser$add_argument("--gene_PCA_table",
                    dest = "gene_pca_table_fp",
                    help = "Filepath to the gene count PCA table as a .tsv.")
args <- parser$parse_args()

#### functions ####
## takes normalized counts table and conducts a pca analysis
## outputs the pca table and plot
run_pca <- function(norm_df,
                    metadata_df,
                    sample_col){
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
  
  ## creating list of outputs 
  my_list <- list(PCATable = count_pca_table,
                  PCAxLab = x_lab,
                  PCAyLab = y_lab)
  return(my_list)
}

## separate function to generate pca plot 
## since we want two separate pcas for bio group and batch 
## by default only plots PC1 and PC2 
plot_pca <- function(pca_table,
                     x_lab,
                     y_lab,
                     fill_by_col,
                     point_size,
                     point_alpha,
                     brewer_palette,
                     legend_title,
                     plot_title){
  
  ## building actual PCA plot using above data
  plot <- pca_table %>% 
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
  
  return(plot)
  
}

## actual analysis
## reading in normalized sgRNA/gene count dataframes
## have to use read.table or else the row names aren't kept
sgRNAnorm_combCounts_df <- read.table(args$norm_sgRNA_count_fp,
                                      check.names = FALSE)
geneNorm_combCounts_df <- read.table(args$norm_gene_count_fp,
                                     check.names = FALSE)
metadata <- read_csv(args$metadata_fp)

#### sgRNA PCA analysis ####
sgRNA_pca_res <- run_pca(norm_df = sgRNAnorm_combCounts_df,
                         metadata_df = metadata,
                         sample_col = 'sampleid')

sgRNA_count_pcaTable <- sgRNA_pca_res$PCATable

## PCA colored by biological_group
bioGroup_sgRNA_pca_plot <- plot_pca(pca_table = sgRNA_count_pcaTable,
                           x_lab = sgRNA_pca_res$PCAxLab,
                           y_lab = sgRNA_pca_res$PCAyLab,
                           fill_by_col = 'biological_group',
                           point_size = 3,
                           point_alpha = 0.6,
                           brewer_palette = 'Dark2',
                           legend_title = 'Biological Group',
                           plot_title = 'sgRNA Count PCA: Biological Group')

## PCA colored by batch
batch_sgRNA_pca_plot <- plot_pca(pca_table = sgRNA_count_pcaTable,
                                 x_lab = sgRNA_pca_res$PCAxLab,
                                 y_lab = sgRNA_pca_res$PCAyLab,
                                 fill_by_col = 'batch',
                                 point_size = 3,
                                 point_alpha = 0.6,
                                 brewer_palette = 'Dark2',
                                 legend_title = 'Batch',
                                 plot_title = 'sgRNA Count PCA: Batch')


#### gene PCA analysis ####
gene_pca_res <- run_pca(norm_df = geneNorm_combCounts_df,
                        metadata_df = metadata,
                        sample_col = 'sampleid')

gene_count_pcaTable <- gene_pca_res$PCATable

## PCA colored by biological_group
bioGroup_gene_pca_plot <- plot_pca(pca_table = gene_count_pcaTable,
                                    x_lab = gene_pca_res$PCAxLab,
                                    y_lab = gene_pca_res$PCAyLab,
                                    fill_by_col = 'biological_group',
                                    point_size = 3,
                                    point_alpha = 0.6,
                                    brewer_palette = 'Dark2',
                                    legend_title = 'Biological Group',
                                    plot_title = 'Gene Count PCA: Biological Group')

## PCA colored by batch
batch_gene_pca_plot <- plot_pca(pca_table = gene_count_pcaTable,
                                 x_lab = gene_pca_res$PCAxLab,
                                 y_lab = gene_pca_res$PCAyLab,
                                 fill_by_col = 'batch',
                                 point_size = 3,
                                 point_alpha = 0.6,
                                 brewer_palette = 'Dark2',
                                 legend_title = 'Batch',
                                 plot_title = 'Gene Count PCA: Batch')

#### saving my outputs ####
## plots - pdf
ggsave(args$bioGroup_sgRNA_pdf_fp,
       plot = bioGroup_sgRNA_pca_plot,
       width = 8,
       height = 6)
ggsave(args$batch_sgRNA_pdf_fp,
       plot = batch_sgRNA_pca_plot,
       width = 8,
       height = 6)


ggsave(args$bioGroup_gene_pdf_fp,
       plot = bioGroup_gene_pca_plot,
       width = 8,
       height = 6)
ggsave(args$batch_gene_pdf_fp,
       plot = batch_gene_pca_plot,
       width = 8,
       height = 6)

## plots - png (for report generation)
ggsave(args$bioGroup_sgRNA_png_fp,
       plot = bioGroup_sgRNA_pca_plot,
       width = 8,
       height = 6)
ggsave(args$batch_sgRNA_png_fp,
       plot = batch_sgRNA_pca_plot,
       width = 8,
       height = 6)


ggsave(args$bioGroup_gene_png_fp,
       plot = bioGroup_gene_pca_plot,
       width = 8,
       height = 6)
ggsave(args$batch_gene_png_fp,
       plot = batch_gene_pca_plot,
       width = 8,
       height = 6)

## PCA result files
write_tsv(sgRNA_count_pcaTable,
          args$sgRNA_pca_table_fp)
write_tsv(gene_count_pcaTable,
          args$gene_pca_table_fp)
