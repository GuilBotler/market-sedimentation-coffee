library(tidyverse)

download_audit <- read_csv(
  "data/audit/download_audit_1999_2025.csv",
  show_col_types = FALSE
)

competition <- read_csv(
  "data/processed/competition_entries.csv",
  show_col_types = FALSE
)

auction_raw <- read_csv(
  "data/processed/auction_raw.csv",
  show_col_types = FALSE
)

process_coverage <- read_csv(
  "data/processed/process_coverage.csv",
  show_col_types = FALSE
)

process_shares <- read_csv(
  "data/processed/process_shares_country_year.csv",
  show_col_types = FALSE
)

download_audit |>
  count(download_status)

download_audit |>
  filter(download_status == "failed") |>
  select(
    country,
    year,
    source_url,
    download_error
  ) |>
  print(n = Inf)


competition |>
  summarise(
    entries = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(
      paste(country, year)
    ),
    first_year = min(year),
    last_year = max(year)
  )

auction_raw |>
  summarise(
    lots = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(
      paste(country, year)
    ),
    first_year = min(year),
    last_year = max(year)
  )

competition |>
  group_by(country) |>
  summarise(
    first_year = min(year),
    last_year = max(year),
    years_observed = n_distinct(year),
    entries = n(),
    .groups = "drop"
  ) |>
  arrange(country) |>
  print(n = Inf)


process_coverage |>
  summarise(
    events = n(),
    complete_events = sum(coverage_rate == 1),
    partial_events = sum(
      coverage_rate > 0 &
        coverage_rate < 1
    ),
    no_process_events = sum(
      coverage_rate == 0
    ),
    mean_coverage = mean(coverage_rate)
  )

process_coverage |>
  filter(coverage_rate < 1) |>
  arrange(
    coverage_rate,
    country,
    year
  ) |>
  print(n = Inf)

process_shares |>
  group_by(
    country,
    year,
    program
  ) |>
  summarise(
    share_all_sum = sum(share_all),
    reported_sum = sum(
      share_reported,
      na.rm = TRUE
    ),
    coverage_rate = first(coverage_rate),
    .groups = "drop"
  ) |>
  filter(
    abs(share_all_sum - 1) > 1e-8 |
      (
        coverage_rate > 0 &
          abs(reported_sum - 1) > 1e-8
      )
  )

competition |>
  filter(year < 2020) |>
  summarise(
    entries = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(
      paste(country, year)
    ),
    process_reported = sum(
      process_family != "Not reported"
    ),
    process_missing = sum(
      process_family == "Not reported"
    )
  )  
  
auction_raw |>
  filter(year < 2020) |>
  summarise(
    lots = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(
      paste(country, year)
    )
  )
