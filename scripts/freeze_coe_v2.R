suppressPackageStartupMessages({
  library(tidyverse)
  library(digest)
})

required <- c(
  "R/expansion_v2/freeze_coe_v2.R",
  "data/processed/v2/competition_entries.rds",
  "data/processed/v2/auction_lots.rds",
  "data/audit/v2/entry_lot_matches.csv"
)
missing <- required[!file.exists(required)]
if (length(missing)) {
  stop("Run from repository root. Missing: ", paste(missing, collapse = ", "))
}

sys.source("R/expansion_v2/freeze_coe_v2.R", envir = .GlobalEnv)
entries <- readRDS("data/processed/v2/competition_entries.rds")
lots <- readRDS("data/processed/v2/auction_lots.rds")
matches <- readr::read_csv(
  "data/audit/v2/entry_lot_matches.csv",
  show_col_types = FALSE
)

frozen_lots <- build_frozen_auction_lots_v2(lots, matches)
entry_lot_panel <- build_entry_lot_panel_v2(entries, frozen_lots)
freeze_summary <- build_freeze_summary_v2(
  entries, frozen_lots, entry_lot_panel
)

output_dir <- "data/final/v2"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

outputs <- c(
  competition_entries = file.path(output_dir, "competition_entries.csv"),
  auction_lots = file.path(output_dir, "auction_lots.csv"),
  entry_lot_panel = file.path(output_dir, "entry_lot_panel.csv"),
  freeze_summary = file.path(output_dir, "freeze_summary.csv")
)

readr::write_csv(entries, outputs[["competition_entries"]])
readr::write_csv(frozen_lots, outputs[["auction_lots"]])
readr::write_csv(entry_lot_panel, outputs[["entry_lot_panel"]])
readr::write_csv(freeze_summary, outputs[["freeze_summary"]])
saveRDS(entries, file.path(output_dir, "competition_entries.rds"))
saveRDS(frozen_lots, file.path(output_dir, "auction_lots.rds"))
saveRDS(entry_lot_panel, file.path(output_dir, "entry_lot_panel.rds"))

commit <- tryCatch(
  system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
  error = function(e) NA_character_
)
manifest <- tibble::tibble(
  data_version = "coe_v2_auction_freeze_1",
  source_commit = dplyr::first(commit, default = NA_character_),
  file = unname(outputs),
  sha256 = purrr::map_chr(unname(outputs), digest::digest,
                         algo = "sha256", file = TRUE)
)
readr::write_csv(manifest, file.path(output_dir, "manifest.csv"))

message(
  "Frozen COE V2 files written to data/final/v2. ",
  "Use eligible_matched_price_sample for the primary remuneration sample."
)
