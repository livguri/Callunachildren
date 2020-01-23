## make plots

plot_plan <- drake_plan(
  garden_location = tribble(~Long, ~Lat, ~Site,
                            5.046309, 61.293201, "Garden"),
  #site map
  site_map = {
    mp <- map_data("worldHires", xlim = c(0, 30), ylim = c(55, 80))
    
    ggplot(meta, aes(x = Long, y = Lat, label = Site)) +
      geom_map(map = mp, data = mp, aes(map_id = region),
              inherit.aes = FALSE, fill = "grey80", colour = "grey70") +
      geom_point() +
      geom_text(hjust = 1.2) +
      #geom_text(data = garden_location, label="★", family = "HiraKakuPro-W3", colour = "red") +
      geom_point(data = garden_location, shape = 8, colour = "red") +
      geom_text(data = garden_location, colour = "red", hjust = -0.1) +
      coord_quickmap() +
      scale_x_continuous(expand = c(0.2, 0)) +
      scale_y_continuous(expand = c(0.1, 0)) +
      labs(x = "°E", y = "°N")
  },
  
  height2.5_mum = calluna %>% 
    ggplot(aes(x = block_mum,
               y = Hight2.5yr, fill = Block)) + 
    geom_boxplot(show.legend = FALSE) +
  
    facet_wrap(~Site, scales = "free_x", nrow = 2) +
    labs(x = "Mother", y = "Height cm") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)),
  
  #mortality
  mortality_plot = calluna %>% 
    group_by(Site, supermum) %>% 
    summarise(prop_alive  = mean(!is.na(Hight2.5yr))) %>% 
    ggplot(aes(x = Site, y = prop_alive)) +
    geom_sina() +
    labs(y = "Proportion alive at 2.5 yr"),
  
 # Height
 calluna_height_thin = calluna %>% 
   select(Site, IdNr, matches("^He?ight")) %>%
   select(-`Hight 2`) %>% 
   rename(Height12 = `Hight 1`) %>% 
   pivot_longer(matches("^He?ight"), names_to = "time", values_to = "height", names_pattern = "(\\d\\.?\\d?)" ) %>% 
   filter(!is.na(height)) %>%
   group_by(IdNr) %>%
   mutate(time_numeric = as.numeric(time), 
          time_numeric = if_else(time_numeric == 8, true = 8/12, false = time_numeric),
          time = case_when(
            time == 8 ~ "8 months", 
            time == 1 ~ "1 year", 
            TRUE ~ paste(time, "years")
          ),
          time = factor(time, levels = c("8 months",  "1 year", "1.5 years", "2.5 years", "3 years", "12 years")),
          delta = height - lag(height)),

  height_plot = calluna_height_thin %>% 
     ggplot(aes(x = Site, y = height, fill = Site)) + 
     geom_boxplot(notch = TRUE, show.legend = FALSE) +
     scale_fill_viridis_d() +
     labs(x = "Site", y = "Height, cm") +
     facet_wrap(~ time, scales = "free_y")
 
)
