## make plots

# site map
make_site_map <- function(metadata, garden_location) {
  mp <- rnaturalearth::ne_countries(scale = 10, returnclass = "sf", country = c("Norway", "Sweden", "Finland"), continent = "Europe")

  ggplot(mp, aes(x = long, y = lat, label = code)) +
    geom_sf(fill = "grey80", colour = "grey70", inherit.aes = FALSE) +
    ggspatial::geom_spatial_point(data = metadata, crs = 4326) +
    ggspatial::geom_spatial_text(data = metadata, hjust = 1.3, crs = 4326) +
    ggspatial::geom_spatial_point(data = garden_location, shape = 8, colour = "red", crs = 4326) +
    ggspatial::geom_spatial_text(data = garden_location, colour = "red", hjust = -0.1, crs = 4326) +
    coord_sf(xlim = c(-400000, 500000), ylim = c(-740000, 680000), expand = FALSE, crs = "+proj=laea +lon_0=10 +lat_0=64.5 +datum=WGS84 +units=m +no_defs") +
    ggspatial::annotation_scale(location = "tl") +
    theme(axis.title = element_blank())
}

plot_height2.5_mum <- function(calluna) {
  calluna |>
    ggplot(aes(
      x = block_mum,
      y = height2_5yr, fill = block
    )) +
    geom_boxplot(show.legend = FALSE) +
    facet_wrap(vars(code), scales = "free_x", nrow = 2) +
    labs(x = "Mother", y = "Height cm") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
}
# mortality
plot_mortality <- function(calluna) {
  calluna |>
    group_by(code, supermum) |>
    summarise(prop_alive = mean(!is.na(height2_5yr)), .groups = "drop") |>
    ggplot(aes(x = code, y = prop_alive)) +
    ggbeeswarm::geom_quasirandom() +
    labs(y = "Proportion alive at 2.5 yr")
}
# Height
make_calluna_height_thin <- function(calluna) {
  calluna |>
    select(site, code, id_nr, matches("^Height")) |>
    select(-height_greening, -height_1, -height_2) |>
    rename(height12 = height_max) |>
    pivot_longer(matches("^Height"), names_to = "time", values_to = "height", names_pattern = "(\\d_?\\d?)") |>
    filter(!is.na(height)) |>
    group_by(id_nr) |>
    mutate(
      time = str_replace(time, "_", "."),
      time_numeric = as.numeric(time),
      time_numeric = if_else(time_numeric == 8, true = 8 / 12, false = time_numeric),
      time = case_when(
        time == 8 ~ "8 months",
        time == 1 ~ "1 year",
        TRUE ~ paste(time, "years")
      ),
      time = factor(time, levels = c("8 months", "1 year", "1.5 years", "2.5 years", "3 years", "12 years")),
      delta = height - lag(height)
    )
}

plot_height <- function(calluna_height_thin) {
  calluna_height_thin |>
    ggplot(aes(x = code, y = height, fill = code)) +
    geom_boxplot(notch = TRUE, show.legend = FALSE) +
    scale_fill_viridis_d() +
    labs(x = "Site", y = "Height, cm") +
    facet_wrap(vars(time), scales = "free_y")
}
