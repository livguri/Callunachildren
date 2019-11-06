## make plots

plot_plan <- drake_plan(
  #site map
  site_map = {
    mp <- map_data("worldHires", xlim = c(0, 30), ylim = c(55, 80))
    
    ggplot(meta, aes(x = Long, y = Lat, label = Site)) +
      geom_map(map = mp, data = mp, aes(map_id = region),
              inherit.aes = FALSE, fill = "grey70", colour = "grey60") +
      geom_point() +
      geom_text(hjust = 1.2) +
      coord_quickmap() +
      scale_x_continuous(expand = c(0.2, 0)) +
      scale_y_continuous(expand = c(0.1, 0)) +
      labs(x = "°E", y = "°N") +
      theme_bw()
  }
)