#### load data####

# biomass data
load_biomass <- function(biomass_data) {
  read_excel(biomass_data, sheet = "Biomass")
}

# common garden data
load_commongarden <- function(commongarden_data, commongarden_corrections_data) {
  Commongarden <- read_excel(commongarden_data, sheet = "Commongarden")

  # clean common garden
  Commongarden <- Commongarden |>
    mutate(
      IdNr = as.numeric(IdNr),
      IdMum = str_remove(Block, "[A-C]"),
      IdMum = as.numeric(IdMum),
      Block = str_remove(Block, "\\d+")
    ) |>
    rename(
      Flowering12 = `Flowering (yes=1, no=0)`,
      Dead12 = `Dead (yes=1, no=0)`,
      Gone12 = `Gone (yes=1, no=0)`
    ) |>
    mutate(
      Flowering12 = Flowering12 == 1, # force TRUE FALSE
      Dead12 = Dead12 == 1,
      Gone12 = Gone12 == 1
    )

  # import garden corrections
  garden_corrections <- read_excel(commongarden_corrections_data, na = "NA") |>
    select(-matches("\\.\\.\\.\\d+")) |>
    filter(!is.na(IdNr)) |>
    mutate(IdNr_new = as.numeric(IdNr_new))

  # correct garden meta data
  Commongarden <- Commongarden |>
    left_join(garden_corrections, by = c("IdNr", "Site", "Block", "IdMum")) |>
    mutate(
      IdNr = coalesce(IdNr_new, IdNr),
      Site = coalesce(Site_new, Site),
      Block = coalesce(Block_new, Block),
      IdMum = coalesce(IdMum_new, IdMum)
    ) |>
    select(-matches("_new$")) |>
    mutate(`Max hight` = if_else(`Max hight` > 100, NA_real_, `Max hight`)) # max height of 137cm is doubtful, especially given 54/56 cm other heights

  Commongarden
}

# greenhouse data
load_greenhouse <- function(greenhouse_data) {
  read_excel(greenhouse_data, sheet = "Greenhouse") |>
    mutate(
      Site = toupper(Site),
      Hight1.5yr = as.numeric(Hight1.5yr)
    )
}

# site meta data
load_metadata <- function(metadata_data) {
  read_excel(metadata_data, sheet = "Ark1") |>
    mutate_at(vars(Lat:Long), as.numeric)
}

#### join datasets ####
combine_datasets <- function(greenhouse, biomass, commongarden, metadata) {
  calluna <- greenhouse |>
    left_join(biomass, by = c("IdNr", "Site", "Block", "IdMum")) |>
    left_join(commongarden, by = c("IdNr", "Site", "Block", "IdMum")) |>
    left_join(metadata, by = "Site") |>
    mutate(
      supermum = paste(Site, Block, IdMum),
      Site = factor(Site),
      Site = fct_reorder(.f = Site, .x = Lat), # sort sites by latitude
      # block_mum for plotting
      block_mum = paste0(Block, IdMum),
      block_mum = fct_reorder(.f = block_mum, IdMum),
      block_mum = fct_reorder(.f = block_mum, as.numeric(as.factor(Block)))
    ) |>
    select(-matches("^\\.\\.\\.\\d+$")) # remove unnamed columns
  calluna
}
