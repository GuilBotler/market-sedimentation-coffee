suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(stringi)
  library(digest)
})

required <- c(
  "R/read_source_registry.R",
  "R/scrape_ace_event.R",
  "R/harmonize.R"
)

missing <- required[!file.exists(required)]
if (length(missing) > 0L) {
  stop("Run from repository root. Missing: ", paste(missing, collapse = ", "))
}

purrr::walk(required, sys.source, envir = .GlobalEnv)

modules <- list.files(
  "R/expansion_v2",
  pattern = "\\.[Rr]$",
  full.names = TRUE
)
purrr::walk(modules, sys.source, envir = .GlobalEnv)

raw_path <- "data/raw/ace_all_tables_v2.rds"
if (!file.exists(raw_path)) {
  stop("Missing local raw cache: ", raw_path, ". Run the full V2 expansion first.")
}

raw_v2 <- readRDS(raw_path)
stages <- split_ace_stages_v2(raw_v2)

competition_v2 <- harmonize_competition_v2(stages$competition)
auction_v2 <- harmonize_auction_v2(stages$auction)
coverage_v2 <- build_process_coverage_v2(competition_v2)
event_shares_v2 <- build_process_shares_v2(competition_v2)
country_year_shares_v2 <- aggregate_country_year_process(event_shares_v2)

purrr::walk(
  c("data/processed/v2", "data/audit/v2"),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
)

saveRDS(competition_v2, "data/processed/v2/competition_entries.rds")
saveRDS(auction_v2, "data/processed/v2/auction_lots.rds")
readr::write_csv(competition_v2, "data/processed/v2/competition_entries.csv")
readr::write_csv(auction_v2, "data/processed/v2/auction_lots.csv")
readr::write_csv(coverage_v2, "data/processed/v2/process_coverage.csv")
readr::write_csv(event_shares_v2, "data/processed/v2/process_shares_event.csv")
readr::write_csv(
  country_year_shares_v2,
  "data/processed/v2/process_shares_country_year.csv"
)

audit_v2 <- build_v2_audit(
  raw_v2,
  competition_v2,
  auction_v2,
  coverage_v2,
  event_shares_v2
)
write_v2_audit(audit_v2)

message(
  "V2 processed data rebuilt from the local raw cache. ",
  "No HTTP requests were made."
)
