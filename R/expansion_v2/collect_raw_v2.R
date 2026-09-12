download_ace_event_v2 <- function(country, year, event_name, event_type, source_url,
                                  user_agent, pause_seconds = 0.5,
                                  cache_dir = "data/raw/events_v2", refresh = FALSE) {
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  cache_file <- file.path(cache_dir, paste0(digest::digest(source_url, algo = "xxhash64"), ".rds"))
  if (!refresh && file.exists(cache_file)) return(readRDS(cache_file))
  message("Downloading: ", country, " ", year, " - ", event_name)
  if (pause_seconds > 0) Sys.sleep(pause_seconds)
  result <- tryCatch({
    out <- scrape_ace_event_v2(country, year, event_name, event_type, source_url, user_agent)
    if (nrow(out) == 0L) stop("Page accessed, but no compatible table was recognized.")
    dplyr::mutate(out, download_status = "success", download_error = NA_character_)
  }, error = function(e) {
    tibble::tibble(
      event_id = digest::digest(source_url, algo = "xxhash64"), country = country,
      year = as.integer(year), event_name = event_name, event_type = event_type,
      source_url = source_url, stage = NA_character_, download_status = "failed",
      download_error = cli::ansi_strip(conditionMessage(e))
    )
  })
  saveRDS(result, cache_file)
  result
}

collect_ace_raw_v2 <- function(registry, cache_dir = "data/raw/events_v2",
                               user_agent = "market-sedimentation-coffee/0.4 academic research",
                               pause_seconds = 0.5, refresh = FALSE) {
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  rows <- registry |>
    dplyr::filter(is.na(active) | active) |>
    dplyr::distinct(source_url, .keep_all = TRUE) |>
    dplyr::arrange(country, year, source_url)

  purrr::pmap_dfr(
    rows |> dplyr::select(country, year, event_name, event_type, source_url),
    function(country, year, event_name, event_type, source_url) {
      cache_file <- file.path(cache_dir, paste0(digest::digest(source_url, algo = "xxhash64"), ".rds"))
      if (!refresh && file.exists(cache_file)) return(readRDS(cache_file))
      out <- download_ace_event_v2(country, year, event_name, event_type, source_url,
                                   user_agent, pause_seconds)
      saveRDS(out, cache_file)
      out
    }
  )
}

build_download_audit_v2 <- function(raw) {
  raw |>
    dplyr::group_by(event_id, country, year, event_name, event_type, source_url,
                    download_status, download_error) |>
    dplyr::summarise(
      competition_rows = sum(stage == "competition", na.rm = TRUE),
      auction_rows = sum(stage == "auction", na.rm = TRUE), .groups = "drop"
    )
}

split_ace_stages_v2 <- function(raw) {
  list(
    competition = raw |>
      dplyr::filter(download_status == "success", stage == "competition"),
    auction = raw |>
      dplyr::filter(download_status == "success", stage == "auction")
  )
}
