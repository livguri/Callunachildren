#### load data####

# biomass data
load_biomass <- function(biomass_data) {
  read_excel(biomass_data, sheet = "Biomass") |> 
    janitor::clean_names()
}

# common garden data
load_commongarden <- function(commongarden_data, commongarden_corrections_data) {
  commongarden <- read_excel(commongarden_data, sheet = "Commongarden") |> 
    janitor::clean_names()

  # clean common garden
  commongarden <- commongarden |>
    mutate(
      id_nr = as.numeric(id_nr),
      id_mum = str_remove(block, "[A-C]"),
      id_mum = as.numeric(id_mum),
      block = str_remove(block, "\\d+")
    ) |>
    rename(
      flowering_12yr = flowering_yes_1_no_0,
      dead_12yr = dead_yes_1_no_0,
      gone_12yr = gone_yes_1_no_0,
      height_max = max_hight,
      height_1 = hight_1,
      height_2 = hight_2,
      height_greening = greening_hight
    ) |>
    mutate(
      Flowering_12yr = flowering_12yr == 1, # force TRUE FALSE
      Dead_12yr = dead_12yr == 1,
      Gone_12yr = gone_12yr == 1
    )

  # import garden corrections
  garden_corrections <- read_excel(commongarden_corrections_data, na = "NA") |>
    select(-matches("\\.\\.\\.\\d+")) |>
    janitor::clean_names() |> 
    filter(!is.na(id_nr)) |>
    mutate(id_nr_new = as.numeric(id_nr_new))

  # correct garden meta data
  commongarden <- commongarden |>
    left_join(garden_corrections, by = c("id_nr", "site", "block", "id_mum")) |>
    mutate(
      id_nr = coalesce(id_nr_new, id_nr),
      site = coalesce(site_new, site),
      block = coalesce(block_new, block),
      id_mum = coalesce(id_mum_new, id_mum)
    ) |>
    select(-matches("_new$")) |>
    
    mutate(max_hight = if_else(height_max > 100, NA_real_, height_max)) # max height of 137cm is doubtful, especially given 54/56 cm other heights

  commongarden
}

# greenhouse data
load_greenhouse <- function(greenhouse_data) {
  read_excel(greenhouse_data, sheet = "Greenhouse") |>
    janitor::clean_names() |> 
    rename_with(.fn = \(x){str_replace(x, "hight", "height")}, .cols = matches("hight")) |> 
    mutate(
      site = toupper(site),
      height1_5yr = as.numeric(height1_5yr)
    )
}

# site meta data
load_metadata <- function(metadata_data, chelsa_gdd5_data) {
  meta <- read_excel(metadata_data, sheet = "Ark1") |>
    janitor::clean_names() |> 
    mutate(
      across(lat:long, as.numeric),
      # make site codes A in north
      code = factor(LETTERS[1:n()]),
      code = fct_reorder(.f = code, .x = lat, .desc = TRUE)
      ) 
  meta_sf <- sf::st_as_sf(meta, coords = c("long", "lat")) 
  sf::st_crs(meta_sf) <- 4326
  climate <- terra::rast(chelsa_gdd5_data) |>
    terra::extract(meta_sf) 

  meta$gdd5 <- pull(climate, stringr::str_replace(basename(chelsa_gdd5_data), "\\.tif", ""))
  meta
}

#### join datasets ####
combine_datasets <- function(greenhouse, biomass, commongarden, metadata) {
  calluna <- greenhouse |>
    left_join(biomass, by = c("id_nr", "site", "block", "id_mum")) |>
    left_join(commongarden, by = c("id_nr", "site", "block", "id_mum")) |>
    left_join(metadata, by = "site") |>
    mutate(
      supermum = paste(site, block, id_mum, sep = "_"),
      # block_mum for plotting
      block_mum = paste0(block, id_mum),
      block_mum = fct_reorder(.f = block_mum, id_mum),
      block_mum = fct_reorder(.f = block_mum, as.numeric(as.factor(block)))
    ) |>
    select(-matches("^\\.\\.\\.\\d+$")) # remove unnamed columns
  calluna
}
