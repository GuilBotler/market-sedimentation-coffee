suppressPackageStartupMessages({
  library(tidyverse)
  library(stringi)
})

required <- c(
  "R/harmonize.R",
  "R/expansion_v2/auction_audit_v2.R",
  "data/processed/v2/competition_entries.rds",
  "data/processed/v2/auction_lots.rds"
)
missing <- required[!file.exists(required)]
if (length(missing)) {
  stop("Run from repository root. Missing: ", paste(missing, collapse = ", "))
}

sys.source("R/harmonize.R", envir = .GlobalEnv)
sys.source("R/expansion_v2/auction_audit_v2.R", envir = .GlobalEnv)

entries <- readRDS("data/processed/v2/competition_entries.rds")
lots <- readRDS("data/processed/v2/auction_lots.rds")
audit <- build_auction_audit_v2(entries, lots)
write_auction_audit_v2(audit)

message(
  "Auction audit completed. Review price coverage and entry-lot match status ",
  "before constructing the analytical matched panel."
)
