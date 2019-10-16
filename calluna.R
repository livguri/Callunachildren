#load packages
library(tidyverse)

#load data
calluna <- readxl::read_excel("Data/Feltskjema Fureneset 25.09.2019.xlsx", sheet = "målingerSept")

calluna <- calluna %>% mutate(`Site name`= factor(`Site name`,levels = c("TR", "NO", "TA", "SM", "AU", "TV", "LY", "HI")))

ggplot(calluna, aes(x = `Site name`, y = `Max hight`)) + 
  geom_boxplot(notch = TRUE)

hightmod <- lm(`Max hight` ~ `Site name`, data = calluna)
summary(hightmod)
