## plots total/transformed sgRNA/gene counts per sample for QC purposes

## needed libraries
library(tidyverse)
library(broom)
library(magrittr)
library(edgeR)
library(stats)
library(argparse)

## argparse to link with snakemake
parser <- ArgumentParser()
parser$add_argument("-cl",
                    "--comb_countLong_table",
                    dest = "comb_count_fp",
                    help = "Filepath to the long version of the total counts table file as a .tsv.")
parser$add_argument("-m",
                    "--metadata",
                    dest = "metadata_fp",
                    help = "Filepath to metadata file in .csv format. 
                    Must have columns named 'sampleid' and 'biological_group'.")
parser$add_argument("-tpd",
                    "--total_count_pdf",
                    dest = "total_count_pdf_fp",
                    help = "Filepath to the total count plot as a .pdf.")
parser$add_argument("-tpn",
                    "--total_count_png",
                    dest = "total_count_png_fp",
                    help = "Filepath to the total count plot as a .png.")
parser$add_argument("-trpd",
                    "--trans_count_pdf",
                    dest = "trans_count_pdf_fp",
                    help = "Filepath to the log2 transformed count plot as a .pdf.")
parser$add_argument("-trpn",
                    "--trans_count_png",
                    dest = "trans_count_png_fp",
                    help = "Filepath to the log2 transformed count plot as a .png.")
parser$add_argument("-tct",
                    "--total_count_table",
                    dest = "total_count_table_fp",
                    help = "Filepath to the total count results table as a .tsv")
parser$add_argument("-trct",
                    "--trans_count_table",
                    dest = "trans_count_table_fp",
                    help = "Filepath to the log2 transformed count results table as a .tsv")
args <- parser$parse_args()

## functions
## calculates the total amount of sgRNA/gene counts per sample and creates a plot
## idk if this will be by biological group instead of sample in the future...
run_total_counts <- function(comb_table,
                             metadata_df,
                             sample_col,
                             fill_by_col,
                             bar_alpha,
                             brewer_palette,
                             x_label,
                             y_label,
                             plot_title){
  ## calculating total counts per sample
  total_counts_table <- comb_table %>% 
    select(.data[[sample_col]], Plus_reads) %>% 
    group_by(.data[[sample_col]]) %>% 
    summarize(total_counts = sum(Plus_reads)) %>% 
    left_join(metadata_df, by = sample_col) 
  
  ## to reorder the x axis so all bio reps are next to each other
  x_axis_order <- unique(unlist(metadata_df[sample_col]))
  
  ## building total counts plot
  total_counts_plot <- total_counts_table %>% 
    ggplot(aes(x = .data[[sample_col]], y = total_counts)) +
    geom_bar(aes(fill = .data[[fill_by_col]]), 
             stat = 'identity', 
             color = 'black', 
             alpha = bar_alpha) +
    scale_x_discrete(limits = factor(x_axis_order)) +
    theme_bw(base_size = 20) +
    scale_fill_brewer(palette = brewer_palette,
                      name = legend_title) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'bottom') +
    labs(x = x_label,
         y = y_label,
         title = plot_title)
  ## creating a list of outputs
  my_list <- list(TotalCountTable = total_counts_table,
                  TotalCountPlot = total_counts_plot)
  return(my_list)
}

## transforms all counts in the Plus_reads column by log2 and builds a plot
run_transform_counts <- function(comb_table,
                                 metadata_df,
                                 sample_col,
                                 fill_by_col,
                                 bar_alpha,
                                 brewer_palette,
                                 legend_title,
                                 x_label,
                                 y_label,
                                 plot_title){
  ## log2 transformation
  transform_count_table <- comb_table %>% 
    mutate(log2_counts = log2(Plus_reads)) %>% 
    left_join(metadata_df, by = sample_col)
  
  ## to reorder the x axis so all bio reps are next to each other
  x_axis_order <- unique(unlist(metadata_df[sample_col]))
  
  ## plot 
  transform_count_plot <- transform_count_table %>% 
    ggplot(aes(x = .data[[sample_col]], y = log2_counts)) +
    geom_boxplot(aes(group = .data[[sample_col]]), width = 0.5, color = 'black') +
    geom_violin(aes(fill = .data[[fill_by_col]]), color = 'black', alpha = bar_alpha) +
    scale_x_discrete(limits = x_axis_order) +
    theme_bw(base_size = 20) +
    scale_fill_brewer(palette = brewer_palette,
                      name = legend_title) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'bottom') +
    labs(x = x_label,
         y = y_label,
         title = plot_title)
  ## creating list of outputs
  my_list <- list(TransformCountTable = transform_count_table,
                  TransformCountPlot = transform_count_plot)
  return(my_list)
}

## actual analysis
comb_counts <- read_tsv(args$comb_count_fp)
metadata <- read_csv(args$metadata_fp)

metadata <- metadata %>% 
  arrange(biological_group)

## total counts 
total_counts_res <- run_total_counts(comb_table = comb_counts,
                                     metadata_df = metadata,
                                     sample_col = 'sampleid',
                                     fill_by_col = 'biological_group',
                                     bar_alpha = 0.6,
                                     brewer_palette = 'Dark2',
                                     legend_title = 'Biological Group',
                                     x_label = 'Sample',
                                     y_label = 'Total Counts',
                                     plot_title = 'Total sgRNA/Gene Counts per Sample')

total_counts_table <- total_counts_res$TotalCountTable
total_counts_plot <- total_counts_res$TotalCountPlot

## transformed (log2) counts
transform_count_res <- run_transform_counts(comb_table = comb_counts,
                                            metadata_df = metadata,
                                            sample_col = 'sampleid',
                                            fill_by_col = 'biological_group',
                                            bar_alpha = 0.6,
                                            brewer_palette = 'Dark2',
                                            legend_title = 'Biological Group',
                                            x_label = 'Sample',
                                            y_label = 'log2(Counts)',
                                            plot_title = 'Transformed sgRNA/Gene Counts')

transform_counts_table <- transform_count_res$TransformCountTable
transform_counts_plot <- transform_count_res$TransformCountPlot

## saving my outputs
## plots - pdf
ggsave(args$total_count_pdf_fp,
       plot = total_counts_plot,
       width = 9.5,
       height = 8)
ggsave(args$trans_count_pdf_fp,
       plot = transform_counts_plot,
       width = 9.5,
       height = 8)

## plots - png
ggsave(args$total_count_png_fp,
       plot = total_counts_plot,
       width = 9.5,
       height = 8)
ggsave(args$trans_count_png_fp,
       plot = transform_counts_plot,
       width = 9.5,
       height = 8)

## result files 
write_tsv(total_counts_table,
          args$total_count_table_fp)
write_tsv(transform_counts_table,
          args$trans_count_table_fp)
