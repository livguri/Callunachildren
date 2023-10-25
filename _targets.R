# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("here", "readxl", "dplyr", "ggplot2", "stringr", "forcats", "tidyr", "rjt.misc"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed

# Replace the target list below with your own:
list(
  # data files
  tar_target(
    name = biomass_data,
    command = here("data", "Biomass.xlsx"),
    format = "file"
  ),
  tar_target(
    name = commongarden_data,
    command = here("data", "Commongarden.xlsx"),
    format = "file"
  ),
  tar_target(
    name = commongarden_corrections_data,
    command = here("data", "Feil i commongarden.xlsx"),
    format = "file"
  ),
  tar_target(
    name = greenhouse_data,
    command = here("data", "Greenhouse.xlsx"),
    format = "file"
  ),
  tar_target(
    name = metadata_data,
    command = here("data", "Metadata.xlsx"),
    format = "file"
  ),
  tar_target(
    name = chelsa_gdd5_data,
    command = here("data", "CHELSA_gdd5_1981-2010_V.2.1.tif"),
    format = "file"
  ),
  tar_target(
    name = authors,
    command = here("authors.csv"),
    format = "file"
  ),
  # import data
  tar_target(
    name = biomass,
    command = load_biomass(biomass_data)
  ),
  tar_target(
    name = metadata,
    command = load_metadata(metadata_data, chelsa_gdd5_data)
  ),
  tar_target(
    name = commongarden,
    command = load_commongarden(commongarden_data, commongarden_corrections_data)
  ),
  tar_target(
    name = greenhouse,
    command = load_greenhouse(greenhouse_data)
  ),
  tar_target(
    name = garden_location,
    command = tibble(long = 5.046309, lat = 61.293201, site = "Garden", code = "Garden")
  ),

  # combine & process datasets
  tar_target(
    name = calluna,
    command = combine_datasets(greenhouse, biomass, commongarden, metadata)
  ),
  tar_target(
    name = calluna_height_thin,
    command = make_calluna_height_thin(calluna)
  ),

  # figures
  tar_target(
    name = site_map,
    command = make_site_map(metadata, garden_location)
  ),
  tar_target(
    name = height2.5_mum_plot,
    command = plot_height2.5_mum(calluna)
  ),
  tar_target(
    name = mortality_plot,
    command = plot_mortality(calluna)
  ),
  tar_target(
    name = height_plot,
    command = plot_height(calluna_height_thin)
  ),

  ## bibliography
  tar_target(
    name = biblio,
    command = "extra/calluna.bib",
    format = "file"
  ),
  tar_target(
    name = biblio2,
    #add extra packages to bibliography
    command = package_citations(
      packages = c("targets", "tidyverse", "quarto", "renv", "lmerTest"), 
      old_bib = biblio, 
      new_bib = "extra/calluna2.bib"),
    format = "file"
  ),
  ## manuscript
  tar_target(
    name = plume_authors,
    command = plume::Plume$new(readr::read_csv(authors), credit_roles = TRUE)
  ),
  tar_quarto(
    name = manuscript,
    path = "calluna6000.qmd",
    extra_files = c("extra/elsevier-harvard_rjt.csl", "extra/calluna2.bib")
  )
)
