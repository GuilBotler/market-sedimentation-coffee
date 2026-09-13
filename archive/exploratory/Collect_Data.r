library(tidyverse)
library(rvest)
library(xml2)
library(httr2)
library(janitor)
library(stringi)

##faz o download

purrr::walk(
  list.files("R", pattern = "\\.R$", full.names = TRUE),
  source
)

registry <- read_source_registry("data-raw/source_registry.csv")

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

download_one_event <- function(country, year, source_url) {
  
  message("Baixando: ", country, " ", year)
  
  tryCatch({
    
    tables <- scrape_ace_event(
      country = country,
      year = year,
      source_url = source_url,
      user_agent = "market-sedimentation-coffee/0.3 academic research"
    )
    
    tables |>
      mutate(
        download_status = "success",
        download_error = NA_character_
      )
    
  }, error = function(e) {
    
    tibble(
      country = country,
      year = year,
      source_url = source_url,
      stage = NA_character_,
      download_status = "failed",
      download_error = conditionMessage(e)
    )
  })
}

raw_download <- purrr::pmap_dfr(
  registry |> select(country, year, source_url),
  download_one_event
)

readr::write_csv(
  raw_download,
  "data/raw/ace_all_tables_2020_2025.csv"
)

competition_raw <- raw_download |>
  filter(
    download_status == "success",
    stage == "competition"
  )

auction_raw <- raw_download |>
  filter(
    download_status == "success",
    stage == "auction"
  )

download_audit <- raw_download |>
  group_by(
    country,
    year,
    source_url,
    download_status,
    download_error
  ) |>
  summarise(
    competition_rows = sum(stage == "competition", na.rm = TRUE),
    auction_rows = sum(stage == "auction", na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(
  competition_raw,
  "data/processed/competition_raw_2020_2025.csv"
)

readr::write_csv(
  auction_raw,
  "data/processed/auction_raw_2020_2025.csv"
)

readr::write_csv(
  download_audit,
  "data/processed/download_audit_2020_2025.csv"
)  

##confere o resultado  
  download_audit |>
    count(download_status)

##VErificar falha 
  download_audit |>
    filter(download_status == "failed") |>
    select(country, year, source_url, download_error)

    competition_raw |>
    summarise(
      origins = n_distinct(country),
      years = n_distinct(year),
      events = n_distinct(paste(country, year))
    )
    
    
    auction_raw |>
      summarise(
        origins = n_distinct(country),
        years = n_distinct(year),
        events = n_distinct(paste(country, year))
      )


    coverage <- full_join(
      competition_raw |>
        count(country, year, name = "competition_rows"),
      auction_raw |>
        count(country, year, name = "auction_rows"),
      by = c("country", "year")
    ) |>
      arrange(country, year)
    
    View(coverage)
        
    coverage |>
      filter(
        is.na(competition_rows) |
          is.na(auction_rows) |
          competition_rows == 0 |
          auction_rows == 0
      )
    
    
  ##Thailandia
    
    download_audit |>
      filter(country == "Thailand", year == 2022) |>
      pull(download_error) |>
      cli::ansi_strip() |>
      cat()    
    