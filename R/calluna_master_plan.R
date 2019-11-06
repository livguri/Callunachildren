####load packages####
library("tidyverse")
library("drake")
library("lme4")
library("here")
library("mapdata")

#### import plans ####
source(here("R", "import_data.R"))
source(here("R", "make_plots.R"))

#### combine plans ####
calluna_plan <- bind_rows(
  import_plan,
  plot_plan
  )

####configure plan####
config <- drake_config(calluna_plan)
config