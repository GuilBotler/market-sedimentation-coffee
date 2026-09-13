repo_path <- "/home/gb/market-sedimentation-coffee"
setwd(repo_path)

zip_file <- file.choose()

extract_dir <- file.path(
  tempdir(),
  "ace_expansion_v2"
)

dir.create(
  extract_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

unzip(
  zip_file,
  exdir = extract_dir
)

source_root <- file.path(
  extract_dir,
  "organized_R_expansion_v2"
)

stopifnot(
  dir.exists(source_root)
)



repo_path <- "/home/gb/market-sedimentation-coffee"
setwd(repo_path)

zip_file <- file.choose()

extract_dir <- file.path(
  tempdir(),
  "ace_expansion_v2"
)

dir.create(
  extract_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

unzip(
  zip_file,
  exdir = extract_dir
)

source_root <- file.path(
  extract_dir,
  "organized_R_expansion_v2"
)

stopifnot(
  dir.exists(source_root)
)


dir.create(
  file.path(repo_path, "R", "expansion_v2"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(repo_path, "scripts"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(repo_path, "tests", "testthat"),
  recursive = TRUE,
  showWarnings = FALSE
)


dir.create(
  file.path(repo_path, "R", "expansion_v2"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(repo_path, "scripts"),
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  file.path(repo_path, "tests", "testthat"),
  recursive = TRUE,
  showWarnings = FALSE
)


#

v2_modules <- list.files(
  file.path(
    source_root,
    "R",
    "expansion"
  ),
  pattern = "\\.[Rr]$",
  full.names = TRUE
)

stopifnot(
  length(v2_modules) == 8
)

file.copy(
  v2_modules,
  file.path(
    repo_path,
    "R",
    "expansion_v2"
  ),
  overwrite = TRUE
)

##

file.copy(
  file.path(
    source_root,
    "scripts",
    "run_expansion_v2.R"
  ),
  file.path(
    repo_path,
    "scripts",
    "run_expansion_v2.R"
  ),
  overwrite = TRUE
)

file.copy(
  file.path(
    source_root,
    "tests",
    "testthat",
    "test-expansion-v2.R"
  ),
  file.path(
    repo_path,
    "tests",
    "testthat",
    "test-expansion-v2.R"
  ),
  overwrite = TRUE
)

list.files(
  "R/expansion_v2"
)


source(
  "scripts/run_expansion_v2.R"
)


## testes 

library(tidyverse)

competition_v2 <- readRDS(
  "data/processed/v2/competition_entries.rds"
)

auction_v2 <- readRDS(
  "data/processed/v2/auction_lots.rds"
)

download_v2 <- read_csv(
  "data/audit/v2/download.csv",
  show_col_types = FALSE
)

coverage_v2 <- read_csv(
  "data/audit/v2/process_coverage.csv",
  show_col_types = FALSE
)

shares_v2 <- read_csv(
  "data/processed/v2/process_shares_event.csv",
  show_col_types = FALSE
)


download_v2 |>
  count(download_status)

download_v2 |>
  filter(download_status == "failed") |>
  select(
    country,
    year,
    event_name,
    download_error
  ) |>
  print(n = Inf)


tibble(
  version = c("V1", "V2"),
  
  competition_entries = c(
    5617,
    nrow(competition_v2)
  ),
  
  auction_lots = c(
    2381,
    nrow(auction_v2)
  ),
  
  competition_events = c(
    NA_integer_,
    n_distinct(competition_v2$event_id)
  ),
  
  auction_events = c(
    NA_integer_,
    n_distinct(auction_v2$event_id)
  )
)

competition_v2 |>
  summarise(
    entries = n(),
    events = n_distinct(event_id),
    country_years = n_distinct(
      paste(country, year)
    ),
    countries = n_distinct(country),
    first_year = min(year),
    last_year = max(year)
  )


auction_v2 |>
  summarise(
    lots = n(),
    events = n_distinct(event_id),
    country_years = n_distinct(
      paste(country, year)
    ),
    countries = n_distinct(country),
    first_year = min(year),
    last_year = max(year)
  )

auction_v2 |>
  group_by(year) |>
  summarise(
    lots = n(),
    events = n_distinct(event_id),
    buyers_reported = sum(
      !is.na(buyer) &
        buyer != ""
    ),
    prices_reported = sum(
      !is.na(final_bid_usd_lb)
    ),
    .groups = "drop"
  ) |>
  arrange(year) |>
  print(n = Inf)

#

competition_v2 |>
  count(
    process_classification_source,
    sort = TRUE
  )


##


competition_v2 |>
  group_by(year) |>
  summarise(
    entries = n(),
    
    row_or_heading = sum(
      process_classification_source %in%
        c(
          "reported process",
          "ACE table heading"
        )
    ),
    
    event_title = sum(
      process_classification_source ==
        "ACE event title"
    ),
    
    missing = sum(
      process_classification_source ==
        "not reported"
    ),
    
    coverage =
      (row_or_heading + event_title) /
      entries,
    
    .groups = "drop"
  ) |>
  arrange(year) |>
  print(n = Inf)


#

competition_v2 |>
  filter(
    process_classification_source ==
      "ACE event title"
  ) |>
  count(
    country,
    year,
    event_name,
    event_type,
    process_family,
    sort = TRUE
  ) |>
  print(n = Inf)

##

competition_v2 |>
  distinct(
    country,
    year,
    event_id,
    event_name,
    event_type
  ) |>
  count(
    country,
    year,
    name = "events"
  ) |>
  filter(events > 1) |>
  arrange(country, year) |>
  print(n = Inf)


#
read_csv(
  "data/audit/v2/duplicate_entries.csv",
  show_col_types = FALSE
)


read_csv(
  "data/audit/v2/duplicate_lots.csv",
  show_col_types = FALSE
)


read_csv(
  "data/audit/v2/share_sums.csv",
  show_col_types = FALSE
) |>
  filter(
    abs(share_all_sum - 1) > 1e-8 |
      (
        coverage_rate > 0 &
          abs(share_reported_sum - 1) >
          1e-8
      )
  )

#

raw_v2 <- readRDS(
  "data/raw/ace_all_tables_v2.rds"
)

raw_competition_v2 <- raw_v2 |>
  filter(
    download_status == "success",
    stage == "competition"
  )

raw_counts <- raw_competition_v2 |>
  count(
    event_id,
    country,
    year,
    event_name,
    name = "raw_rows"
  )

clean_counts <- competition_v2 |>
  count(
    event_id,
    country,
    year,
    event_name,
    name = "entries"
  )

entry_reduction <- full_join(
  raw_counts,
  clean_counts,
  by = c(
    "event_id",
    "country",
    "year",
    "event_name"
  )
) |>
  mutate(
    raw_rows = replace_na(raw_rows, 0L),
    entries = replace_na(entries, 0L),
    removed = raw_rows - entries
  )

#

entry_reduction |>
  filter(removed != 0) |>
  arrange(desc(abs(removed))) |>
  print(n = Inf)
