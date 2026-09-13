library(tidyverse)

raw_v2 <- readRDS(
  "data/raw/ace_all_tables_v2.rds"
)

entry_reduction <- read_csv(
  "data/audit/v2/entry_reduction.csv",
  show_col_types = FALSE
)

critical_events <- entry_reduction |>
  filter(retention_rate < 0.5) |>
  pull(event_id)

critical_events


raw_v2 |>
  filter(
    event_id %in% critical_events,
    stage == "competition"
  ) |>
  count(
    country,
    year,
    event_name,
    source_table_id,
    program,
    process_group,
    name = "rows"
  ) |>
  arrange(country, source_table_id) |>
  print(n = Inf)

#audit 171

setwd("~/market-sedimentation-coffee")

library(tidyverse)

competition_v2 <- readRDS(
  "data/processed/v2/competition_entries.rds"
)

raw_v2 <- readRDS(
  "data/raw/ace_all_tables_v2.rds"
)

raw_counts <- raw_v2 |>
  filter(
    download_status == "success",
    stage == "competition"
  ) |>
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
    removed = raw_rows - entries,
    retention_rate = if_else(
      raw_rows > 0,
      entries / raw_rows,
      NA_real_
    )
  ) |>
  arrange(desc(abs(removed)), country, year)

dir.create(
  "data/audit/v2",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  entry_reduction,
  "data/audit/v2/entry_reduction.csv"
)


# total

entry_reduction |>
  summarise(
    raw_rows = sum(raw_rows),
    entries = sum(entries),
    removed = sum(removed),
    events_with_reduction = sum(removed != 0)
  )

#list

entry_reduction |>
  filter(removed != 0) |>
  select(
    country,
    year,
    event_name,
    raw_rows,
    entries,
    removed,
    retention_rate
  ) |>
  print(n = Inf)

#

entry_reduction |>
  filter(
    entries == 0 |
      removed < 0 |
      retention_rate < 0.5
  ) |>
  print(n = Inf)


#feedback

entry_reduction |>
  filter(removed != 0) |>
  summarise(events_with_reduction = n())


critical_events <- entry_reduction |>
  filter(retention_rate < 0.5) |>
  pull(event_id)

raw_v2 |>
  filter(
    event_id %in% critical_events,
    stage == "competition"
  ) |>
  count(
    country,
    year,
    event_name,
    source_table_id,
    program,
    process_group,
    name = "rows"
  ) |>
  arrange(country, source_table_id) |>
  print(n = Inf)


## feedback

entry_reduction |>
  filter(removed != 0) |>
  summarise(events_with_reduction = n())

critical_events <- entry_reduction |>
  filter(retention_rate < 0.5) |>
  pull(event_id)

raw_v2 |>
  filter(
    event_id %in% critical_events,
    stage == "competition"
  ) |>
  count(
    country,
    year,
    event_name,
    source_table_id,
    program,
    process_group,
    name = "rows"
  ) |>
  arrange(country, source_table_id) |>
  print(n = Inf)

critical_rows <- raw_v2 |>
  filter(
    event_id %in% critical_events,
    stage == "competition"
  ) |>
  mutate(
    rank_raw = as.character(
      pick_column(
        raw_v2,
        c(
          "rank",
          "ranking",
          "lot",
          "lot_number",
          "position"
        )
      )
    ),
    score_raw = ace_number(
      pick_column(
        raw_v2,
        c(
          "score",
          "cupping_score",
          "final_score"
        )
      )
    ),
    farm_raw = pick_column(
      raw_v2,
      c("farm_cws", "farm_name", "farm")
    ),
    process_raw = pick_column(
      raw_v2,
      c("process", "processing", "proceso", "processo")
    ),
    variety_raw = pick_column(
      raw_v2,
      c("variety", "varietal", "variedad", "variedade")
    )
  )

critical_rows |>
  count(
    country,
    year,
    program,
    process_group,
    rank_raw,
    score_raw,
    farm_raw,
    process_raw,
    variety_raw,
    name = "copies"
  ) |>
  filter(copies > 1) |>
  arrange(country, rank_raw) |>
  print(n = Inf)


##erro chat

critical_base <- raw_v2 |>
  filter(
    event_id %in% critical_events,
    stage == "competition"
  )

critical_rows <- critical_base |>
  mutate(
    rank_raw = as.character(
      pick_column(
        critical_base,
        c(
          "rank",
          "ranking",
          "lot",
          "lot_number",
          "position"
        )
      )
    ),
    score_raw = ace_number(
      pick_column(
        critical_base,
        c(
          "score",
          "cupping_score",
          "final_score"
        )
      )
    ),
    farm_raw = pick_column(
      critical_base,
      c("farm_cws", "farm_name", "farm")
    ),
    process_raw = pick_column(
      critical_base,
      c(
        "process",
        "processing",
        "proceso",
        "processo"
      )
    ),
    variety_raw = pick_column(
      critical_base,
      c(
        "variety",
        "varietal",
        "variedad",
        "variedade"
      )
    )
  )

nrow(critical_base)
nrow(critical_rows)


exact_duplicates <- critical_rows |>
  count(
    country,
    year,
    program,
    process_group,
    rank_raw,
    score_raw,
    farm_raw,
    process_raw,
    variety_raw,
    name = "copies"
  ) |>
  filter(copies > 1) |>
  arrange(country, rank_raw)

exact_duplicates |>
  print(n = Inf, width = Inf)


critical_base |>
  count(
    country,
    year,
    event_name,
    source_table_id,
    program,
    process_group,
    name = "rows"
  ) |>
  arrange(country, source_table_id) |>
  print(n = Inf, width = Inf)

#
identity_rows <- critical_rows |>
  mutate(
    farm_key = normalize_key_text(farm_raw),
    variety_key = normalize_key_text(variety_raw)
  ) |>
  filter(
    !is.na(farm_key),
    farm_key != ""
  ) |>
  distinct(
    country,
    source_table_id,
    rank_raw,
    score_raw,
    farm_raw,
    farm_key,
    variety_raw,
    variety_key
  )

table_overlap <- identity_rows |>
  inner_join(
    identity_rows,
    by = c(
      "country",
      "farm_key",
      "score_raw"
    ),
    suffix = c("_left", "_right"),
    relationship = "many-to-many"
  ) |>
  filter(
    source_table_id_left <
      source_table_id_right
  ) |>
  count(
    country,
    source_table_id_left,
    source_table_id_right,
    name = "matching_coffees"
  ) |>
  arrange(
    country,
    desc(matching_coffees)
  )

table_overlap |>
  print(n = Inf, width = Inf)

identity_rows |>
  inner_join(
    identity_rows,
    by = c(
      "country",
      "farm_key",
      "score_raw"
    ),
    suffix = c("_left", "_right"),
    relationship = "many-to-many"
  ) |>
  filter(
    source_table_id_left <
      source_table_id_right
  ) |>
  select(
    country,
    source_table_id_left,
    source_table_id_right,
    farm_raw_left,
    score_raw,
    rank_raw_left,
    rank_raw_right,
    variety_raw_left,
    variety_raw_right
  ) |>
  arrange(
    country,
    source_table_id_left,
    rank_raw_left
  ) |>
  print(n = 30, width = Inf)

#

overlap_examples <- identity_rows |>
  inner_join(
    identity_rows,
    by = c(
      "country",
      "farm_key",
      "score_raw"
    ),
    suffix = c("_left", "_right"),
    relationship = "many-to-many"
  ) |>
  filter(
    source_table_id_left <
      source_table_id_right
  )

overlap_examples |>
  filter(country != "Costa Rica") |>
  select(
    country,
    source_table_id_left,
    source_table_id_right,
    farm_raw_left,
    score_raw,
    rank_raw_left,
    rank_raw_right,
    variety_raw_left,
    variety_raw_right
  ) |>
  arrange(
    country,
    source_table_id_left,
    rank_raw_left
  ) |>
  print(n = Inf, width = Inf)

critical_rows |>
  group_by(
    country,
    source_table_id,
    program,
    process_group
  ) |>
  summarise(
    rows = n(),
    farms_reported = sum(
      !is.na(farm_raw) &
        farm_raw != ""
    ),
    scores_reported = sum(
      !is.na(score_raw)
    ),
    processes_reported = sum(
      !is.na(process_raw) &
        process_raw != ""
    ),
    varieties_reported = sum(
      !is.na(variety_raw) &
        variety_raw != ""
    ),
    first_ranks = paste(
      head(rank_raw, 5),
      collapse = ", "
    ),
    .groups = "drop"
  ) |>
  print(n = Inf, width = Inf)

#

summary_tables <- tribble(
  ~event_id,           ~source_table_id,
  "183f05090c9a1140",  11L,
  "730e5b8120156480",   5L,
  "95f3bb26fec856b9",   5L
)

stages_v2 <- split_ace_stages_v2(raw_v2)

competition_raw_corrected <- stages_v2$competition |>
  anti_join(
    summary_tables,
    by = c(
      "event_id",
      "source_table_id"
    )
  )

competition_corrected <- harmonize_competition_v2(
  competition_raw_corrected
)

tibble(
  version = c(
    "V2 atual",
    "Sem tabelas-resumo"
  ),
  entries = c(
    nrow(competition_v2),
    nrow(competition_corrected)
  )
)

competition_corrected |>
  filter(event_id %in% critical_events) |>
  count(
    country,
    year,
    program,
    process_group,
    name = "entries"
  ) |>
  arrange(
    country,
    program,
    process_group
  ) |>
  print(n = Inf)

#
competition_corrected |>
  count(
    event_id,
    program,
    entry_key
  ) |>
  filter(n > 1) |>
  print(n = Inf)

#

base_url <- paste0(
  "https://raw.githubusercontent.com/",
  "GuilBotler/market-sedimentation-coffee/main/"
)

files <- c(
  "R/expansion_v2/harmonize_v2.R",
  "R/expansion_v2/audit_v2.R",
  "tests/testthat/test-expansion-v2.R"
)

for (file in files) {
  download.file(
    paste0(base_url, file),
    destfile = file,
    mode = "wb"
  )
}
#
source("scripts/run_expansion_v2.R")

#correcao

download.file(
  paste0(
    "https://raw.githubusercontent.com/",
    "GuilBotler/market-sedimentation-coffee/main/",
    "R/expansion_v2/harmonize_v2.R"
  ),
  destfile = "R/expansion_v2/harmonize_v2.R",
  mode = "wb"
)

source("scripts/run_expansion_v2.R")

readr::read_csv(
  "data/audit/v2/sparse_summary_tables.csv",
  show_col_types = FALSE
) |>
  print(n = Inf)

readRDS(
  "data/processed/v2/competition_entries.rds"
) |>
  dplyr::summarise(
    entries = dplyr::n(),
    events = dplyr::n_distinct(event_id),
    countries = dplyr::n_distinct(country),
    first_year = min(year),
    last_year = max(year)
  )


entries <- readRDS(
  "data/processed/v2/competition_entries.rds"
)

entries |>
  dplyr::filter(
    country %in% c(
      "Costa Rica",
      "Honduras",
      "Nicaragua"
    ),
    year == 2024
  ) |>
  dplyr::group_by(
    country,
    year,
    program,
    process_group
  ) |>
  dplyr::summarise(
    entries = dplyr::n(),
    process_reported = sum(
      !is.na(process_raw) &
        process_raw != ""
    ),
    variety_reported = sum(
      !is.na(variety_raw) &
        variety_raw != ""
    ),
    .groups = "drop"
  ) |>
  dplyr::arrange(
    country,
    program,
    process_group
  ) |>
  print(n = Inf, width = Inf)



entries <- readRDS(
  "data/processed/v2/competition_entries.rds"
)

entries |>
  dplyr::filter(
    country %in% c("Costa Rica", "Honduras", "Nicaragua"),
    year == 2024
  ) |>
  dplyr::group_by(country, year, program, process_group) |>
  dplyr::summarise(
    entries = dplyr::n(),
    process_reported = sum(!is.na(process_raw) & process_raw != ""),
    variety_reported = sum(!is.na(variety_raw) & variety_raw != ""),
    .groups = "drop"
  ) |>
  dplyr::arrange(country, program, process_group) |>
  print(n = Inf, width = Inf)


#

names(entries)

grep(
  "process|variety",
  names(entries),
  value = TRUE,
  ignore.case = TRUE
)


entries |>
  dplyr::filter(
    country %in% c("Costa Rica", "Honduras", "Nicaragua"),
    year == 2024
  ) |>
  dplyr::group_by(
    country,
    year,
    program,
    process_group
  ) |>
  dplyr::summarise(
    entries = dplyr::n(),
    process_reported = sum(
      !is.na(process) & process != ""
    ),
    variety_reported = sum(
      !is.na(variety) & variety != ""
    ),
    .groups = "drop"
  ) |>
  dplyr::arrange(
    country,
    program,
    process_group
  ) |>
  print(n = Inf, width = Inf)

names(entries)
