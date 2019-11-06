library("drake")
library("here")
loadNamespace("visNetwork")

r_make(source = here("R", "calluna_master_plan.R"))

r_vis_drake_graph(source = here("R", "calluna_master_plan.R"))

browseURL("calluna6000.html")
