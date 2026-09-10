library(targets)

tar_option_set(
  packages = c("tidyverse", "rvest", "xml2", "janitor", "httr2", "stringi", "here", "digest", "fixest")
)

purrr::walk(list.files("R", pattern = "\\.R$", full.names = TRUE), source)

config <- project_config()

list(
  tar_target(registry, read_source_registry(config$registry)),
  tar_target(
    event_raw,
    purrr::pmap_dfr(
      registry |> dplyr::select(country, year, source_url),
      function(country, year, source_url) {
        scrape_ace_event(country, year, source_url, config$user_agent)
      }
    )
  ),
  tar_target(auction_lots, harmonize_ace_tables(event_raw)),
  tar_target(metrics, differentiation_metrics(auction_lots)),
  tar_target(models, fit_baseline_models(auction_lots)),
  tar_target(
    processed_csv,
    readr::write_csv(auction_lots, config$processed_csv),
    format = "file"
  )
)
