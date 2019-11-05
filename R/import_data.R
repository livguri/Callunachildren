#### Data script 
library("readxl")

import_plan <- drake_plan(
  ####load data####
  #biomass data
  Biomass = read_excel(file_in(!!here("Data", "Biomass.xlsx")), sheet = "Biomass"),
  
  #common garden data
  Commongarden0 = read_excel(file_in(!!here("Data", "Commongarden.xlsx")), sheet = "Commongarden"),
  
  #greenhouse data
  Greenhouse = read_excel(file_in(!!here("Data", "Greenhouse.xlsx")), sheet = "Greenhouse") %>%
    mutate(Site = toupper(Site)),
  
  #site meta data
  meta = read_excel(file_in(!!here("Data", "Metadata.xlsx")), sheet = "Ark1") %>% 
    mutate_at(vars(Lat:Long), as.numeric),
  
  ####clean data####
  Commongarden = Commongarden0 %>% 
    mutate(
      IdNr = as.numeric(IdNr),
      IdMum = str_remove(Block, "[A-C]"),
      IdMum = as.numeric(IdMum), 
      Block = str_remove(Block, "\\d+")),
  
  #### join datasets ####
  calluna = Greenhouse %>% 
    left_join(Biomass, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
    left_join(Commongarden, by = c("IdNr", "Site", "Block", "IdMum")) %>%
    left_join(meta, by = "Site") %>% 
    mutate(supermum=paste(Site,Block,IdMum))
)
  