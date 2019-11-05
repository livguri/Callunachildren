####load packages####
library(tidyverse)
library(lme4)

####load data####
Biomass <- readxl::read_excel("Data/Biomass.xlsx", sheet = "Biomass")

Commongarden0 <- readxl::read_excel("Data/Commongarden.xlsx", sheet = "Commongarden")

Greenhouse <- readxl::read_excel("Data/Greenhouse.xlsx", sheet = "Greenhouse") %>%
  mutate(Site = toupper(Site))

#check IDs

Biomass %>% count(Site)
Greenhouse %>% count(Site)
Commongarden0 %>% count(Site)
Commongarden0 %>% filter(str_detect(IdNr, "\\D"))

####clean data####
Commongarden <- Commongarden0 %>% 
  mutate(
    IdNr = as.numeric(IdNr),
    IdMum = str_remove(Block, "[A-C]"),
    IdMum = as.numeric(IdMum), 
    Block = str_remove(Block, "\\d+"))

Biomass %>% anti_join(Greenhouse, by = c("IdNr"))
Biomass %>% anti_join(Greenhouse, by = c("IdNr", "Site")) %>% select(IdNr, Site, Block, IdMum)
Biomass %>% anti_join(Greenhouse, by = c("IdNr", "Site", "Block", "IdMum"))


Commongarden %>% anti_join(Greenhouse, by = c("IdNr"))
Commongarden %>% anti_join(Greenhouse, by = c("IdNr", "Site", "Block", "IdMum"))
Commongarden %>% anti_join(Greenhouse, by = c("IdNr", "Site"))

Greenhouse %>% anti_join(
  bind_rows(
    biomass = Biomass %>% select(IdNr, Site, Block, IdMum),
    common = Commongarden %>% select(IdNr, Site, Block, IdMum),
    .id = "dataset"
  ), by =  c("IdNr", "Site", "Block", "IdMum"))


# joining datasets
calluna <- Greenhouse %>% 
  left_join(Biomass, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
  left_join(Commongarden, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
  mutate(supermum=paste(Site,Block,IdMum))



calluna %>% filter(!is.na(`Max hight`)) %>% count(Site,Block,IdMum) %>% arrange(n)

calluna <- calluna %>% mutate(Site= factor(Site,levels = c("TR", "NO", "TA", "SM", "AU", "TV", "LY", "HI")))

ggplot(calluna, aes(x = Site, y = `Kar8`)) + 
  geom_boxplot(notch = TRUE)

hightmod <- lmer(`Max hight` ~ Site + (1|supermum), data = calluna)
summary(hightmod)
anova(hightmod, )
