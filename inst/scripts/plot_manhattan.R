#!/usr/bin/env Rscript --verbose

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Exit if no command line arguments given
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cmd_args <- commandArgs(trailingOnly=TRUE)
if (length(cmd_args) == 0){
  stop("\n\nNo argumments provided. Run with --help for options.\n\n")
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Loading libraries (this is slow)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

library(magrittr)
library(optparse)
library(grassGEA)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Command line options                                                    -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# If I read the config first I can show the actual defaults here!!!
default_config <- get_script_config()

option_list <- c(
  optparse::make_option(
    "--rds_dir", default = default_config$rds_dir,
    type = "character",
    help= paste0("RDS file directory")
  ),

  optparse::make_option(
    "--png_dir", default = default_config$png_dir,
    type = "character",
    help= "Output directory for GLM results.\n\t\t[default %default]"),

  optparse::make_option(
    "--trait", default = default_config$trait,
    type = "character",
    help= "sol_VL"),

  optparse::make_option(
    "--config_file", default = default_config_file(),
    type = "character",
    help = "configuration file, YAML format.\n\t\t[default %default]")

)

usage <-  "%prog [options]"
opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)
args
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Initializing configuration ----
# How to merge config with opts depending on what are you testing
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# custom ----
#
# This case is the most common and useful to test custom configuration.
# omitting command line arguments usually when running the code from Rstudio
# while editing the config yaml to test different config values.
#
 custom_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
#
 opts <- init_config(args, mode = 'custom', config_file = custom_file)

# cmd_line ----
#
# Useful to test the script when run from shell using Rscript.
# the main intended use and the typical case when run in HPC.
# command line options  will overide config specs
#

# opts <- init_config(args, mode = 'cmd_line')

# default ----
#
# This case is very rare.
# Testing script with just the default config file no command line input.
# this case will test config.yaml in extdata from the R installation as is.
#
# opts <- init_config(args, mode = 'default')

log_opts(opts)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Start script                                                              ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Setting output prefix

opts$time_suffix <- time_suffix()

# Logging

log_time()


rds_files<- list.files(opts$rds_dir,".RDS")

genome_stats <- lapply(rds_files, FUN = function(file){
  rds_full_path <- file.path( opts$rds_dir,file)
  tasGLM <- readRDS(rds_full_path)
  tasGLM$GLM_Stats %>% as.data.frame()
}) %>% dplyr::bind_rows()


genome_plot <- manhattanPlot(
  assocStats = genome_stats,
  trait = opts$trait,
  threshold = 50
)

dir.create(opts$png_dir)
ggplot2::ggsave(
  genome_plot,
  width = 12, height = 4,
  filename = file.path(
                opts$png_dir,
                paste0(opts$trait,".png")),
  dpi =300
)


library(qqplotr)

colnames(genome_stats)
set.seed(0)
smp <- data.frame(norm = rnorm(100))

gg <- ggplot(data = smp, mapping = aes(sample = norm)) +
  stat_qq_band() +
  stat_qq_line() +
  stat_qq_point() +
  labs(x = "Theoretical Quantiles", y = "Sample Quantiles")
gg

qq <- gg_qqplot(genome_stats$p) +
  theme_bw(base_size = 24) +
  theme(
    axis.ticks = element_line(size = 0.5),
    panel.grid = element_blank()
    # panel.grid = element_line(size = 0.5, color = "grey80")
  )

ggsave("~/Desktop/mlm_qqplot.png", plot = qq)



genome_stats$Chr <- as.numeric(genome_stats$Chr)
class(genome_stats$Chr)
source("/Users/fvrodriguez/Desktop/sorghum/fastman/fastman.R")

quartz(height = 4, width = 12)

fastman (genome_stats, chr = "Chr", bp = "Pos", p = "p", maxP = 90)

source("/Users/fvrodriguez/Desktop/sorghum/fastman/fastqq.R")

quartz()
fastqq(genome_stats$p)

?fastman

colnames(genome_stats)
fastman(genome_stats)
colnames(genome_stats)


mlm_dir <- "/Users/fvrodriguez/Desktop/sorghum/rds"
mlm_dir <- "/Users/fvrodriguez/Desktop/Zea_traits/rds"

rds_files<- list.files(mlm_dir,".RDS")

genome_stats <- lapply(rds_files, FUN = function(file){
  rds_full_path <- file.path( mlm_dir,file)
  print(rds_full_path)
  tasMLM <- readRDS(rds_full_path)
  # tasMLM <- readRDS("/Users/fvrodriguez/Desktop/sorghum/rds/mlm_ext_P20_10_20220406_17_00.RDS")
  # tasMLM$MLM_Stats %>% as.data.frame()
  tasMLM$GLM_Stats %>% as.data.frame()
}) %>% dplyr::bind_rows()

genome_stats$Pos <- as.numeric(genome_stats$Pos)

quartz(height = 4, width = 12)
fastman (genome_stats, chr = "Chr", bp = "Pos", p = "p", maxP = 90)


quartz()
fastqq(genome_stats$p)

genome_stats %>%
  filter(Chr==8) %>%
  arrange(p) %>% head()
