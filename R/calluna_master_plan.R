####load packages####
library("conflicted")
library("tidyverse")
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
conflict_prefer("map", "purrr")
library("drake")
library("lme4")
library("here")
library("mapdata")
library("ggforce")


#### import plans ####
source(here("R", "import_data.R"))
source(here("R", "make_plots.R"))

#### manuscript plan ####
manuscript_plan <- drake_plan(
  manuscript = rmarkdown::render(input = knitr_in(!!here("calluna6000.Rmd")))
)


#### combine plans ####
calluna_plan <- bind_rows(
  import_plan,
  plot_plan, 
  manuscript_plan
  )

####configure plan####
config <- drake_config(calluna_plan)
config