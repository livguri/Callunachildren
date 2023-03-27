# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("here", "readxl", "dplyr", "ggplot2", "stringr", "forcats", "tidyr"), # packages that your targets need to run
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
  # import data
  tar_target(
    name = biomass,
    command = load_biomass(biomass_data)
  ),
  tar_target(
    name = metadata,
    command = load_metadata(metadata_data)
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
    command = tibble(Long = 5.046309, Lat = 61.293201, Site = "Garden")
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

  ## manuscript
  tar_quarto(
    name = manuscript,
    path = "calluna6000.qmd"
  )
)
