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
library("rjtmisc")

#force package required
requireNamespace("citr")

#### import plans ####
source(here("R", "import_data.R"))
source(here("R", "make_plots.R"))

#### manuscript plan ####
manuscript_plan <- drake_plan(
  
  #add extra packages to bibliography
  biblio2 = package_citations(
    packages = c("tidyverse"), 
    old_bib = file_in(!!here("extra", "callunaMS.bib")), 
    new_bib = file_out(!!here("extra", "callunaMS2.bib"))),
  
  #render manuscript
  manuscript = {
    #force dependancies on csl and bib files
    file_in(!!here("extra", "elsevier-harvard_rjt.csl"))
    file_in(!!here("extra", "calluna2.bib"))
    
    #render
    rmarkdown::render(input = knitr_in(!!here("calluna6000.Rmd")))
    }
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