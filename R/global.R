#
#
suppressPackageStartupMessages({
  library(tidyverse)
  library(magrittr)
  library(shinyWidgets)
  library(plotly)
})

source("plot_module.R")

df <- read_csv("../Data/sveriges_radio_P3_2018_2021_TOT.csv")

ch_year  <- unique(df$year) %>% rev()

ch_cat   <- c(Title="title",
              Artist="artist",
              Recordlabel="recordlabel",
              Albumname="albumname")
