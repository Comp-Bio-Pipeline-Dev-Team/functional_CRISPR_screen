## runs correlation analysis on the sgRNA/gene count wide dataframes and outputs
## a heatmap of results

## needed libraries
library(tidyverse)
library(broom)
library(magrittr)
library(edgeR)
library(stats)
library(corrplot)
library(corrr)
library(argparse)

## argparse to link with snakemake
parser <- ArgumentParser()
parser$add_argument("-sw",
                    "--sgRNA_counts_wide",
                    dest = "sgRNA_count_wide_fp",
                    help = "Filepath to the wide version of the sgRNA counts table file as a .tsv.")
parser$add_argument("-gw",
                    "--gene_counts_wide",
                    dest = "gene_count_wide_fp",
                    help = "Filepath to the wide version of the gene counts table file as a .tsv.")
parser$add_argument("-scpd",
                    "--sgRNA_corr_pdf",
                    dest = "sgRNA_corr_pdf_fp",
                    help = "Filepath to the sgRNA count correlation heatmap as a .pdf.")
parser$add_argument("-scpn",
                    "--sgRNA_corr_png",
                    dest = "sgRNA_corr_png_fp",
                    help = "Filepath to the sgRNA count correlation heatmap as a .png.")
parser$add_argument("-gcpd",
                    "--gene_corr_pdf",
                    dest = "gene_corr_pdf_fp",
                    help = "Filepath to the gene count correlation heatmap as a .pdf.")
parser$add_argument("-gcpn",
                    "--gene_corr_png",
                    dest = "gene_corr_png_fp",
                    help = "Filepath to the gene count correlation heatmap as a .png.")
parser$add_argument("-sgct",
                    "--sgRNA_corr_table",
                    dest = "sgRNA_corr_table_fp",
                    help = "Filepath to the sgRNA count correlation matrix as a .tsv.")
parser$add_argument("-gct",
                    "--gene_corr_table",
                    dest = "gene_corr_table_fp",
                    help = "Filepath to the gene count correlation matrix as a .tsv.")
args <- parser$parse_args()

## functions
## runs correlation analysis on non-normalized counts data and creates a heat map of results
run_correlation <- function(wide_count_df,
                            corr_method,
                            text_size,
                            legend_bar_height,
                            legend_text_size,
                            legend_box_spacing){
  ## running correlation analysis
  corr_matrix <- cor(wide_count_df,
                     method = corr_method)
  
  proc_corr_matrix <- corr_matrix %>% 
    as_tibble(rownames = 'group1') %>% 
    gather(-group1, key = 'group2', value = 'corr_value')
  
  ## creating plot 
  corr_plot <- proc_corr_matrix %>% 
    ggplot(aes(x = group1, y = group2)) +
    geom_tile(color = 'black', fill = 'white') +
    theme_bw(base_size = 20) +
    geom_text(aes(label = round(corr_value, digits = 2), color = corr_value), 
              size = text_size,
              fontface = 'bold') +
    scale_color_gradientn(colors = hcl.colors(200, 'RdBu'),
                          limits = c(-1, 1),
                          breaks = c(1, 0.8, 0.6, 0.4, 0.2, 0, -0.2, -0.4, -0.6, -0.8, -1),
                          labels = c(1, 0.8, 0.6, 0.4, 0.2, 0, -0.2, -0.4, -0.6, -0.8, -1)) +
    scale_x_discrete(position = 'top') +
    theme(axis.text = element_text(color = 'red'),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          axis.text.x = element_text(angle = 90, hjust = 0),
          legend.frame = element_rect(color = 'black', linetype = 'solid', linewidth = 0.25),
          legend.ticks = element_blank(),
          legend.text = element_text(size = legend_text_size),
          legend.title = element_blank(),
          legend.key.height = unit(legend_bar_height, 'null'),
          legend.key.width = unit(10, 'pt'),
          legend.box.spacing = unit(legend_box_spacing, 'cm'),
          legend.location = "align",
          legend.justification = "right")
  
  ## creating list of outputs
  my_list <- list(CorrMatrix = proc_corr_matrix,
                  CorrPlot = corr_plot)
  return(my_list)
}

## actual analysis
## reading in dataframes
sgRNA_combCounts_wide_df <- read.table(args$sgRNA_count_wide_fp,
                                       check.names = FALSE)
gene_combCounts_wide_df <- read.table(args$gene_count_wide_fp,
                                      check.names = FALSE)

## sgRNA correlation analysis
sgRNA_corr_res <- run_correlation(wide_count_df = sgRNA_combCounts_wide_df,
                                  corr_method = 'spearman',
                                  text_size = 5,
                                  legend_bar_height = 1,
                                  legend_text_size = 12,
                                  legend_box_spacing = -0.1)

sgRNA_corr_matrix <- sgRNA_corr_res$CorrMatrix
sgRNA_corr_plot <- sgRNA_corr_res$CorrPlot

## gene correlation analysis
gene_corr_res <- run_correlation(wide_count_df = gene_combCounts_wide_df,
                                 corr_method = 'spearman',
                                 text_size = 5,
                                 legend_bar_height = 1,
                                 legend_text_size = 12,
                                 legend_box_spacing = -0.1)

gene_corr_matrix <- gene_corr_res$CorrMatrix
gene_corr_plot <- gene_corr_res$CorrPlot

## saving my outputs
## plots - pdf
ggsave(args$sgRNA_corr_pdf_fp,
       plot = sgRNA_corr_plot,
       width = 11,
       height = 9)
ggsave(args$gene_corr_pdf_fp,
       plot = gene_corr_plot,
       width = 11,
       height = 9)

## plots - png
ggsave(args$sgRNA_corr_png_fp,
       plot = sgRNA_corr_plot,
       width = 11,
       height = 9)
ggsave(args$gene_corr_png_fp,
       plot = gene_corr_plot,
       width = 11,
       height = 9)

## correlation result files 
write_tsv(sgRNA_corr_matrix,
          args$sgRNA_corr_table_fp)
write_tsv(gene_corr_matrix,
          args$gene_corr_table_fp)

