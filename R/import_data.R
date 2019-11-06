#### Data script 
library("readxl")

import_plan <- drake_plan(
  ####load data####
  #biomass data
  Biomass = read_excel(file_in(!!here("Data", "Biomass.xlsx")), sheet = "Biomass"),
  
  #common garden data
  Commongarden = {
    Commongarden <- read_excel(file_in(!!here("Data", "Commongarden.xlsx")), sheet = "Commongarden")

    #clean common garden
    Commongarden <- Commongarden %>% 
      mutate(
        IdNr = as.numeric(IdNr),
        IdMum = str_remove(Block, "[A-C]"),
        IdMum = as.numeric(IdMum), 
        Block = str_remove(Block, "\\d+"))
    
    #import garden corrections
    garden_corrections <- read_xlsx(file_in(!!here("Data", "Feil i commongarden.xlsx")), na = "NA") %>% 
      select(-matches("\\.\\.\\.\\d+")) %>% 
      filter(!is.na(IdNr)) %>% 
      mutate(IdNr_new = as.numeric(IdNr_new))
    
    #correct garden meta data        
    Commongarden <- Commongarden %>% 
      left_join(garden_corrections, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
      mutate(
        IdNr = coalesce(IdNr_new, IdNr),
        Site = coalesce(Site_new, Site),
        Block = coalesce(Block_new, Block), 
        IdMum = coalesce(IdMum_new, IdMum)
      ) %>% 
      select(-matches("_new$"))
    
      Commongarden
    },
  
  #greenhouse data
  Greenhouse = read_excel(file_in(!!here("Data", "Greenhouse.xlsx")), sheet = "Greenhouse") %>%
    mutate(
      Site = toupper(Site), 
      Hight1.5yr = as.numeric(Hight1.5yr)
    ),
  
  #site meta data
  meta = read_excel(file_in(!!here("Data", "Metadata.xlsx")), sheet = "Ark1") %>% 
    mutate_at(vars(Lat:Long), as.numeric),
  
  
  #### join datasets ####
  calluna = Greenhouse %>% 
    left_join(Biomass, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
    left_join(Commongarden, by = c("IdNr", "Site", "Block", "IdMum")) %>%
    left_join(meta, by = "Site") %>% 
    mutate(
      supermum = paste(Site,Block,IdMum),
      Site = factor(Site), 
      Site = fct_reorder(.f = Site, .x = Lat)#sort sites by latitude
    ) %>% 
    select(-matches("^\\.\\.\\.\\d+$"))#remove unnamed columns
)
  


