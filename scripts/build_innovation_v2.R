suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

required <- c(
  "R/harmonize.R",
  "R/expansion_v2/process_taxonomy.R",
  "R/expansion_v2/innovation_v2.R",
  "data/final/v2/competition_entries.rds",
  "data/final/v2/entry_lot_panel.rds"
)
missing <- required[!file.exists(required)]
if (length(missing)) {
  stop(
    "Run from repository root after scripts/freeze_coe_v2.R. Missing: ",
    paste(missing, collapse = ", ")
  )
}

sys.source("R/harmonize.R", envir = .GlobalEnv)
sys.source("R/expansion_v2/process_taxonomy.R", envir = .GlobalEnv)
sys.source("R/expansion_v2/innovation_v2.R", envir = .GlobalEnv)

entries <- readRDS("data/final/v2/competition_entries.rds")
entry_lot_panel <- readRDS("data/final/v2/entry_lot_panel.rds")

taxonomy_audit <- build_process_taxonomy_audit_v2(entries)
innovation_entries <- build_innovation_entries_v2(entries)
innovation_country_year <- build_innovation_country_year_v2(
  innovation_entries
)
base_process_country_year <- build_base_process_country_year_v2(
  innovation_entries
)
innovation_remuneration <- build_innovation_remuneration_v2(
  entry_lot_panel,
  innovation_entries
)
innovation_sample_summary <- build_innovation_sample_summary_v2(
  entries,
  innovation_entries,
  innovation_remuneration
)

output_dir <- "data/final/v2"
readr::write_csv(
  taxonomy_audit,
  file.path(output_dir, "process_taxonomy_audit.csv")
)
readr::write_csv(
  innovation_entries,
  file.path(output_dir, "innovation_entries.csv")
)
readr::write_csv(
  innovation_country_year,
  file.path(output_dir, "innovation_country_year.csv")
)
readr::write_csv(
  base_process_country_year,
  file.path(output_dir, "base_process_country_year.csv")
)
readr::write_csv(
  innovation_remuneration,
  file.path(output_dir, "innovation_remuneration_lots.csv")
)
readr::write_csv(
  innovation_sample_summary,
  file.path(output_dir, "innovation_sample_summary.csv")
)

message(
  "Innovation V2 files written to data/final/v2. ",
  "Treat 2018 appearances as left-censored, not as new technologies."
)
