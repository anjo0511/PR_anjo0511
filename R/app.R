#
#
library(shiny)
source("global.R")

if(!require('tabulate', character.only = TRUE)) devtools::install_github("markitr/tabulate")

ui <- fluidPage(
  h2("P3 Radio tracker 2018 - 2021 | Top 50 most played"),
  plot_UI("top_module"),
  plot_UI("bottom_module")
)


server <- function(input, output, session) {
  
  plot_SERVER("top_module", df)
  plot_SERVER("bottom_module",df)
}

shinyApp(ui, server)

