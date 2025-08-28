# Preamble ----

## Install Libraries ----

# Install the petersenlab package:

install.packages("remotes")
remotes::install_github("DevPsyLab/petersenlab")

## Load Libraries ----

# Load the nflreadr, progressr, and tidyverse packages:

library("nflreadr")
library("progressr")
library("tidyverse")

## Load Data ----

# Load the data file that is in the following location: `./Data/player_stats_weekly.Rdata`:

load(file = "./Data/player_stats_weekly.Rdata")

## Download Data ----

# Download the injuries data and load it into an object called `nfl_injuries`:

nfl_injuries <- progressr::with_progress(
  nflreadr::load_injuries(seasons = TRUE))

# Characteristics of the Data ----

## Variable Names ----

# Identify the variable names in the data file:

names(player_stats_weekly)

## Data Structure ----

# Examine the data structure:

str(player_stats_weekly)

## Data Dimensions ----

# Determine the dimensions (i.e., the number of rows and columns) of the data:

dim(player_stats_weekly)

## Number of Missing Elements ----

# Determine how many missing (`NA`) elements there are in the data file:

length(which(is.na(player_stats_weekly)))

## Number of Non-Missing Elements ----

# Determine how many non-missing elements there are in the data file:

length(which(!is.na(player_stats_weekly)))

## View the Data ----

player_stats_weekly

View(player_stats_weekly)

# Data Processing ----

## Subsetting ----

# 1. Create a new object, called `mydata`, that includes just Running Backs and Wide Receivers from seasons 2023 and 2024.
# Keep just the following columns:

#- `player_id`
#- `display_name`
#- `season`
#- `week`
#- `fantasyPoints`

mydata <- player_stats_weekly %>% 
  filter(position %in% c("RB","WR")) %>% 
  filter(season %in% c(2023,2024)) %>% 
  select(player_id, display_name, season, week, fantasyPoints)

## Long to Wide ----

# 2. Create a new object, `mydata_wide`, that widens `mydata` by season and week:

mydata_wide <- mydata %>% 
  tidyr::pivot_wider(
    names_from = c(season, week),
    names_prefix = "fantasyPoints_",
    values_from = fantasyPoints
  )

## Wide to Long ----

# 3. Create a new object, `mydata_long`, that lengthens the data by season and week:

mydata_long <- mydata_wide %>% 
  tidyr::pivot_longer(
    cols = starts_with("fantasyPoints_"),
    names_to = c("prefix", "season", "week"),
    names_sep = "_",
    values_to = "fantasyPoints"
  ) %>%
  dplyr::mutate(
    season = as.integer(season),
    week = as.integer(week)
  ) %>%
  dplyr::select(-prefix)

## Merging ----

# Merge the `player_stats_weekly` object with the `nfl_injuries` object by player, season, and week.
# The player's ID is labeled `player_id` in the `player_stats_weekly` object; it is labeled `gsis_id` in the `nfl_injuries` object.
# Merge so that you only keep the records from `player_stats_weekly` object:

merged_data <- left_join(
  player_stats_weekly,
  nfl_injuries,
  by = c("player_id" = "gsis_id", "season", "week")
)

# Session Info ----

sessionInfo()
