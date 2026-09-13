suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

read_layer <- function(rds_path, csv_path) {
  if (file.exists(rds_path)) {
    readRDS(rds_path)
  } else if (file.exists(csv_path)) {
    readr::read_csv(csv_path, show_col_types = FALSE)
  } else {
    stop("Missing input: ", rds_path, " or ", csv_path)
  }
}

safe_variance <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) >= 2L) stats::var(x) else NA_real_
}

reported_text <- function(x) {
  !is.na(x) & trimws(as.character(x)) != ""
}

entries <- read_layer(
  "data/processed/v2/competition_entries.rds",
  "data/processed/v2/competition_entries.csv"
)

lots <- read_layer(
  "data/processed/v2/auction_lots.rds",
  "data/processed/v2/auction_lots.csv"
)

output_dir <- "data/analysis/v2"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

duplicate_entries <- entries |>
  count(event_id, program, entry_key, name = "copies") |>
  filter(copies > 1L)

duplicate_lots <- lots |>
  count(event_id, program, lot_key, name = "copies") |>
  filter(copies > 1L)

if (nrow(duplicate_entries) > 0L || nrow(duplicate_lots) > 0L) {
  stop("Duplicate entry or lot keys remain. Review the V2 audit.")
}

entry_activity <- entries |>
  group_by(country, year, program) |>
  summarise(
    events = n_distinct(event_id),
    entries = n(),
    scores_reported = sum(!is.na(score)),
    varieties_reported = sum(reported_text(variety)),
    processes_classified = sum(process_family != "Not reported"),
    process_coverage_rate = processes_classified / entries,
    .groups = "drop"
  )

process_measurement <- entries |>
  count(
    country,
    year,
    program,
    process_classification_source,
    name = "entries"
  ) |>
  group_by(country, year, program) |>
  mutate(
    total_entries = sum(entries),
    share_of_entries = entries / total_entries
  ) |>
  ungroup()

process_composition <- entries |>
  count(country, year, program, process_family, name = "entries") |>
  group_by(country, year, program) |>
  mutate(
    total_entries = sum(entries),
    reported_entries = sum(entries[process_family != "Not reported"]),
    missing_process = sum(entries[process_family == "Not reported"]),
    coverage_rate = reported_entries / total_entries,
    share_all = entries / total_entries,
    share_reported = if_else(
      process_family != "Not reported" & reported_entries > 0L,
      entries / reported_entries,
      NA_real_
    )
  ) |>
  ungroup() |>
  arrange(country, year, program, process_family)

share_check <- process_composition |>
  filter(process_family != "Not reported", reported_entries > 0L) |>
  group_by(country, year, program) |>
  summarise(share_sum = sum(share_reported), .groups = "drop") |>
  filter(abs(share_sum - 1) > 1e-8)

if (nrow(share_check) > 0L) {
  stop("Reported process shares do not sum to one.")
}

score_statistics <- entries |>
  group_by(country, year, program) |>
  summarise(
    entries = n(),
    n_score = sum(is.finite(score)),
    mean_score = if_else(n_score > 0L, mean(score, na.rm = TRUE), NA_real_),
    variance_score = safe_variance(score),
    median_score = if_else(n_score > 0L, median(score, na.rm = TRUE), NA_real_),
    min_score = if_else(n_score > 0L, min(score, na.rm = TRUE), NA_real_),
    max_score = if_else(n_score > 0L, max(score, na.rm = TRUE), NA_real_),
    .groups = "drop"
  )

auction_activity <- lots |>
  group_by(country, year, program) |>
  summarise(
    auction_events = n_distinct(event_id),
    lots = n(),
    prices_reported = sum(is.finite(final_bid_usd_lb) & final_bid_usd_lb > 0),
    weights_reported = sum(is.finite(weight_lb) & weight_lb > 0),
    buyers_reported = sum(reported_text(buyer)),
    distinct_buyer_labels = n_distinct(buyer[reported_text(buyer)]),
    total_weight_lb = if_else(
      weights_reported > 0L,
      sum(weight_lb[is.finite(weight_lb) & weight_lb > 0], na.rm = TRUE),
      NA_real_
    ),
    total_value_usd = if_else(
      sum(is.finite(total_value_usd) & total_value_usd > 0) > 0L,
      sum(total_value_usd[is.finite(total_value_usd) & total_value_usd > 0],
          na.rm = TRUE),
      NA_real_
    ),
    .groups = "drop"
  )

price_statistics <- lots |>
  mutate(valid_price = is.finite(final_bid_usd_lb) & final_bid_usd_lb > 0) |>
  group_by(country, year, program) |>
  summarise(
    lots = n(),
    n_price = sum(valid_price),
    mean_price_usd_lb = if_else(
      n_price > 0L,
      mean(final_bid_usd_lb[valid_price]),
      NA_real_
    ),
    variance_price_usd_lb = safe_variance(final_bid_usd_lb[valid_price]),
    median_price_usd_lb = if_else(
      n_price > 0L,
      median(final_bid_usd_lb[valid_price]),
      NA_real_
    ),
    min_price_usd_lb = if_else(
      n_price > 0L,
      min(final_bid_usd_lb[valid_price]),
      NA_real_
    ),
    max_price_usd_lb = if_else(
      n_price > 0L,
      max(final_bid_usd_lb[valid_price]),
      NA_real_
    ),
    .groups = "drop"
  )

country_year_panel <- full_join(
  entry_activity,
  auction_activity,
  by = c("country", "year", "program")
) |>
  arrange(country, year, program)

sample_summary <- tibble(
  layer = c("competition entries", "auction lots"),
  observations = c(nrow(entries), nrow(lots)),
  events = c(n_distinct(entries$event_id), n_distinct(lots$event_id)),
  countries = c(n_distinct(entries$country), n_distinct(lots$country)),
  first_year = c(min(entries$year, na.rm = TRUE), min(lots$year, na.rm = TRUE)),
  last_year = c(max(entries$year, na.rm = TRUE), max(lots$year, na.rm = TRUE))
)

invalid_values <- bind_rows(
  entries |>
    filter(!is.na(score), score < 0 | score > 100) |>
    transmute(layer = "competition", event_id, country, year, program,
              variable = "score", value = score),
  lots |>
    filter(!is.na(final_bid_usd_lb), final_bid_usd_lb <= 0) |>
    transmute(layer = "auction", event_id, country, year, program,
              variable = "final_bid_usd_lb", value = final_bid_usd_lb)
)

write_csv(sample_summary, file.path(output_dir, "sample_summary.csv"))
write_csv(country_year_panel, file.path(output_dir, "country_year_panel.csv"))
write_csv(process_measurement, file.path(output_dir, "process_measurement_sources.csv"))
write_csv(process_composition, file.path(output_dir, "process_composition_country_year.csv"))
write_csv(score_statistics, file.path(output_dir, "score_statistics_country_year.csv"))
write_csv(auction_activity, file.path(output_dir, "auction_activity_country_year.csv"))
write_csv(price_statistics, file.path(output_dir, "price_statistics_country_year.csv"))
write_csv(invalid_values, file.path(output_dir, "invalid_values.csv"))

message(
  "Descriptive V2 outputs written to ", output_dir,
  ". Review process coverage before interpreting process shares."
)
