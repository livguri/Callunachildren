library("drake")
library("tidyverse")


#### Plots ####

loadd(calluna)

ggplot(calluna, aes(x = Site, y = Hight1yr)) + 
  geom_boxplot(notch = TRUE)
ggplot(calluna, aes(x = Site, y = Hight1.5yr)) + 
  geom_boxplot(notch = TRUE)

ggplot(calluna, aes(x = Hight2.5yr, fill = as.factor(Flowering2.5yr))) + geom_bar()
ggplot(calluna, aes(x = Hight1.5yr)) + geom_bar()
ggplot(calluna, aes(x = Hight8m)) + geom_bar()



calluna_height_thin <- calluna %>% 
  select(Site, IdNr, matches("^He?ight")) %>%
  select(-`Hight 2`) %>% 
  rename(Height12 = `Hight 1`) %>% 
  pivot_longer(matches("^He?ight"), names_to = "time", values_to = "height", names_pattern = "(\\d\\.?\\d?)" ) %>% 
  filter(!is.na(height)) %>%
  group_by(IdNr) %>%
mutate(time = as.numeric(time), 
       time = if_else(time == 8, true = 8/12, false = time),
       delta = height - lag(height)) 

calluna_height_thin %>% 
  ggplot(aes(x = time, y = delta, group = IdNr)) + 
  geom_line(alpha = 0.5) +
  facet_wrap(~Site)

calluna_height_thin %>% 
  ggplot(aes(x = time, y = height, group = IdNr)) + 
  geom_line(alpha = 0.5) +
  facet_wrap(~Site)

calluna_height_thin %>% 
  ggplot(aes(x = factor(time), y = height, fill = Site)) + 
  geom_boxplot()

calluna %>% 
  select(Site, IdNr, matches("^He?ight"), `Dead12`, `Gone12`) %>% 
  group_by(Site) %>% 
  summarise(year1 = mean(is.na(Hight1yr)))

#flowering
calluna %>% ggplot(aes(x = Site, y = `Hight 1`, fill = factor(Flowering12))) +
  geom_boxplot()

calluna %>% ggplot(aes(x = Site, y = `Hight 1`, fill = factor(Flowering12))) +
  geom_boxplot()


ggplot(calluna, aes(x = `Max hight`, y = (`Diameter 1` + `Diameter 2`)/2, colour = Flowering12)) + 
  geom_point(data = select(calluna, -Site), colour = "grey80") + 
  geom_abline() +
  geom_point(alpha = 0.5, show.legend = FALSE) + 
  facet_wrap(~Site)
  
calluna %>% ggplot(aes(x = `Hight 1`, y = `Hight 2`, colour = Site)) + geom_point()  
  
calluna %>% 
  ggplot(aes(x = `Diameter 1`, y = `Diameter 2`, colour = Site)) +
  geom_point()  


calluna %>% 
  ggplot(aes(x = pmax(`Hight 1` + `Hight 2`), y = `Greening hight`, colour = Site)) +
  geom_abline()+
  geom_point()

calluna %>% 
  ggplot(aes(x = `Max hight`, y = `Greening hight`, colour = Site)) +
  geom_abline()+
  geom_point(data = select(calluna, -Site), colour = "grey80") + 
  geom_point() + 
  geom_smooth() +
  facet_wrap(~Site)

calluna %>% 
  ggplot(aes(x = Site, y = `Greening hight`/`Max hight`, fill = Site)) +
  geom_violin(draw_quantiles = 0.5)


names(Biomass)
calluna %>% ggplot(aes(x = Weight3yr, y = Dryweight3yr)) +
  geom_point() +
  geom_abline() 

calluna %>% filter(Weight3yr < 100) %>% 
  ggplot(aes(x = Weight3yr, y = Dryweight3yr)) +
  geom_point() +
  geom_abline() +
  geom_abline(slope = 0.5)

calluna %>% filter(Weight3yr < 100) %>% 
  ggplot(aes(x = Dryweight3yr, y = Height3yr)) +
  geom_point() 

calluna %>% filter(Weight3yr < 100) %>% 
  ggplot(aes(x = LengthShoot3yr, y = Height3yr)) +
  geom_point() +
  geom_abline()


calluna %>% filter(Weight3yr < 100) %>% 
  ggplot(aes(x = Site, y = Height3yr)) +
  geom_boxplot()


calluna %>% filter(!is.na(Gone12)) %>% ggplot(aes(x = Site, fill = Dead12 | Gone12)) + geom_bar(position = "fill")


calluna %>% filter(!is.na(Gone12), is.na(Dead12 | Gone12)) %>% 
  select(-(Hight8m:Flowering2.5yr), -(Name:supermum)) %>% 
  glimpse()
       
Commongarden %>% count(Dead12, Gone12)
            
Commongarden %>% filter(!Dead12, Gone12) %>% glimpse()
Commongarden %>% filter(!Dead12, is.na(Gone12)) %>% glimpse()
Commongarden %>% filter(Dead12, Gone12) %>% glimpse()
Commongarden %>% filter(Dead12, is.na(Gone12)) %>% glimpse()
Commongarden %>% filter(is.na(Dead12), !Gone12) %>% glimpse()
Commongarden %>% filter(is.na(Dead12), is.na(Gone12)) %>% glimpse()


calluna %>% mutate(dead8 = is.na(Hight8m)) %>% 
  ggplot(aes(x = Site, fill = dead8)) + geom_bar()
calluna %>% mutate(dead8 = is.na(Hight2.5yr)) %>% 
  ggplot(aes(x = Site, fill = dead8)) + geom_bar()

calluna %>% 
  select(IdNr, Site, matches("^NumbShoots")) %>% 
  pivot_longer(matches("^NumbShoots"), names_to = "time", values_to = "No_shoots", names_pattern = "(\\d\\.?\\d?)", names_ptypes = list(time = numeric())) %>% 
  mutate(time = if_else(time == 8, 8/12, time), 
         time = factor(format(time, digits = 1), levels = c("0.7", "1.0", "1.5"))) %>% 
  ggplot(aes(x = Site, y = No_shoots, fill = time)) +
    geom_violin(draw_quantiles = 0.5, width = 2) +
  facet_wrap(~Site, nrow = 1, scales = "free_x") +
  theme(legend.position = "bottom")

calluna %>% 
  ggplot(aes(x = Site, y = NumbShoots8m)) + 
  geom_violin(draw_quantiles = 0.5, width = 1)
calluna %>% 
  ggplot(aes(x = Site, y = NumbShoots1yr)) + 
  geom_violin(draw_quantiles = 0.5)
calluna %>% 
  ggplot(aes(x = Site, y = NumbShoots1.5yr)) + 
  geom_violin(draw_quantiles = 0.5)
calluna %>% 
  ggplot(aes(x = Site, y = NumbShoots1.5yr)) + 
  geom_violin(draw_quantiles = 0.5)

names(calluna)
calluna %>% ggplot(aes(x = Site, y = as.numeric(`Drought damage (%)`))) + geom_boxplot()

calluna %>% group_by(Site) %>% 
  filter(!is.na(Gone12), !Gone12, !Dead12) %>% 
  summarise(n_mum = n_distinct(supermum) )




calluna %>% 
  ggplot(aes(x = supermum, y = NumbShoots1.5yr, fill = Block)) + 
  geom_boxplot() +
  facet_wrap(~Site, scales = "free_x")


calluna %>% 
  ggplot(aes(x = supermum, y = Hight1.5yr, fill = Block)) + 
  geom_boxplot() +
  facet_wrap(~Site, scales = "free_x")

calluna %>% 
  filter(`Max hight` < 100, !Dead12) %>% 
  ggplot(aes(x = supermum, y = `Max hight`)) + 
  geom_boxplot() +
  facet_wrap(~Site, scales = "free_x")

calluna %>% 
  filter(Dryweight3yr < 10) %>% 
  ggplot(aes(x = supermum, y = Dryweight3yr, fill = Block)) + 
  geom_boxplot() +
  facet_wrap(~Site, scales = "free_x")

calluna %>% filter(!Dead12) %>% 
  ggplot(aes(x = Hight2.5yr, y = `Max hight`)) + 
  geom_point() +
  facet_wrap(~Site)
