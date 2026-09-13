suppressPackageStartupMessages({
  library(tidyverse); library(rvest); library(xml2); library(httr2)
  library(janitor); library(stringi); library(cli)
})

required <- c("R/read_source_registry.R", "R/scrape_ace_event.R", "R/harmonize.R")
missing <- required[!file.exists(required)]
if (length(missing)) stop("Run from repository root. Missing: ", paste(missing, collapse = ", "))
purrr::walk(required, source)
purrr::walk(list.files("R/expansion", pattern = "\\.R$", full.names = TRUE), source)

purrr::walk(c("data/raw", "data/processed", "data/audit"),
            dir.create, recursive = TRUE, showWarnings = FALSE)
current <- read_source_registry("data-raw/source_registry.csv")
historical <- discover_ace_archive(1999L, 2019L)
readr::write_csv(historical, "data/audit/historical_candidates_1999_2019.csv")
if (anyNA(historical$country)) warning("Unidentified historical countries remain; inspect the audit.")
expanded <- combine_source_registries(current, dplyr::filter(historical, !is.na(country)))
readr::write_csv(expanded, "data-raw/source_registry_expanded.csv")

raw <- collect_ace_raw(expanded)
readr::write_csv(raw, "data/raw/ace_all_tables_1999_2025.csv")
readr::write_csv(build_download_audit(raw), "data/audit/download_audit_1999_2025.csv")
stages <- split_ace_stages(raw)
competition <- harmonize_competition_only(stages$competition)
coverage <- build_process_coverage(competition)
shares <- build_process_shares(competition)
readr::write_csv(competition, "data/processed/competition_entries.csv")
readr::write_csv(stages$auction, "data/processed/auction_raw.csv")
readr::write_csv(coverage, "data/processed/process_coverage.csv")
readr::write_csv(shares, "data/processed/process_shares_country_year.csv")
write_competition_audit(audit_competition(stages$competition, competition))
message("Expansion completed. Review data/audit before analysis.")
