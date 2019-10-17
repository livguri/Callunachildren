#load packages
library(tidyverse)
library(lme4)

#load data
Biomass <- readxl::read_excel("Data/Biomass.xlsx", sheet = "Biomass")

GreenGarden0 <- readxl::read_excel("Data/GreenGarden.xlsx", sheet = "GreenGarden")

Greenhouse <- readxl::read_excel("Data/Greenhouse.xlsx", sheet = "Greenhouse") %>%
  mutate(Site = toupper(Site))

#check IDs

Biomass %>% count(Site)
Greenhouse %>% count(Site)
GreenGarden0 %>% count(Site)
GreenGarden0 %>% filter(str_detect(IdNr, "\\D"))

GreenGarden <- GreenGarden0 %>% 
  mutate(
    IdNr = as.numeric(IdNr),
    IdMum = str_remove(Block, "[A-C]"),
    IdMum = as.numeric(IdMum), 
    Block = str_remove(Block, "\\d+"))

Biomass %>% anti_join(Greenhouse, by = c("IdNr"))
Biomass %>% anti_join(Greenhouse, by = c("IdNr", "Site", "Block", "IdMum"))

GreenGarden %>% anti_join(Greenhouse, by = c("IdNr"))
GreenGarden %>% anti_join(Greenhouse, by = c("IdNr", "Site", "Block", "IdMum"))

# joining datasets
calluna <- Greenhouse %>% 
  left_join(Biomass, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
  left_join(GreenGarden, by = c("IdNr", "Site", "Block", "IdMum")) %>% 
  mutate(supermum=paste(Site,Block,IdMum))



calluna %>% filter(!is.na(`Max hight`)) %>% count(Site,Block,IdMum) %>% arrange(n)

calluna <- calluna %>% mutate(Site= factor(Site,levels = c("TR", "NO", "TA", "SM", "AU", "TV", "LY", "HI")))

ggplot(calluna, aes(x = Site, y = `Kar8`)) + 
  geom_boxplot(notch = TRUE)

hightmod <- lmer(`Max hight` ~ Site + (1|supermum), data = calluna)
summary(hightmod)
anova(hightmod, )
