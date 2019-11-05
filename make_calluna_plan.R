library("drake")
library("here")

r_make(source = here("R", "calluna_master_plan.R"))

r_vis_drake_graph(source = here("R", "calluna_master_plan.R"))

browseURL("kustkarnor.html")
