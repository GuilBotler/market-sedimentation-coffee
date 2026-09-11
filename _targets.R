library(targets)

tar_option_set(
  packages = c("tidyverse", "rvest", "xml2", "janitor", "httr2", "stringi", "here", "digest", "fixest", "readxl")
)

purrr::walk(list.files("R", pattern = "\\.R$", full.names = TRUE), source)

config <- project_config()

list(
  tar_target(registry, read_source_registry(config$registry)),
  tar_target(collection, collect_ace_registry(registry, config$user_agent)),
  tar_target(auction_lots, collection$data),
  tar_target(source_audit, collection$audit),
  tar_target(
    commodity_prices,
    collect_market_benchmarks(
      config$world_bank_monthly_url,
      config$fred_wine_url,
      start_year = 1999L
    )
  ),
  tar_target(metrics, differentiation_metrics(auction_lots)),
  tar_target(models, fit_baseline_models(auction_lots)),
  tar_target(
    processed_csv,
    {
      readr::write_csv(auction_lots, config$processed_csv)
      config$processed_csv
    },
    format = "file"
  ),
  tar_target(
    source_audit_csv,
    {
      readr::write_csv(source_audit, config$source_audit_csv)
      config$source_audit_csv
    },
    format = "file"
  ),
  tar_target(
    commodity_csv,
    {
      readr::write_csv(commodity_prices, config$commodity_csv)
      config$commodity_csv
    },
    format = "file"
  )
)
