####load packages####
library("tidyverse")
library("drake")
library("lme4")
library("here")

#### import plans ####
source(here("R", "import_data.R"))


#### combine plans ####
calluna_plan <- bind_rows(
  import_plan
  )

####configure plan####
config <- drake_config(calluna_plan)
config