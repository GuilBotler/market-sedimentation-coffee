download_ace_event_safe <- function(country, year, source_url,
                                    user_agent = "market-sedimentation-coffee/0.3 academic research",
                                    pause_seconds = 0.5) {
  message("Downloading: ", country, " ", year, " - ", source_url)
  if (pause_seconds > 0) Sys.sleep(pause_seconds)
  tryCatch({
    out <- scrape_ace_event(country, year, source_url, user_agent)
    if (nrow(out) == 0L) stop("Page accessed, but no compatible table was recognized.")
    dplyr::mutate(out, download_status = "success", download_error = NA_character_)
  }, error = function(e) {
    tibble::tibble(
      country = country, year = as.integer(year), source_url = source_url,
      stage = NA_character_, download_status = "failed",
      download_error = cli::ansi_strip(conditionMessage(e))
    )
  })
}

collect_ace_raw <- function(registry, pause_seconds = 0.5) {
  registry |>
    dplyr::filter(is.na(active) | active) |>
    dplyr::distinct(country, year, source_url) |>
    dplyr::arrange(country, year, source_url) |>
    dplyr::select(country, year, source_url) |>
    purrr::pmap_dfr(download_ace_event_safe, pause_seconds = pause_seconds)
}

build_download_audit <- function(raw) {
  raw |>
    dplyr::group_by(country, year, source_url, download_status, download_error) |>
    dplyr::summarise(
      competition_rows = sum(stage == "competition", na.rm = TRUE),
      auction_rows = sum(stage == "auction", na.rm = TRUE), .groups = "drop"
    )
}

split_ace_stages <- function(raw) {
  list(
    competition = raw |> dplyr::filter(download_status == "success", stage == "competition"),
    auction = raw |> dplyr::filter(download_status == "success", stage == "auction")
  )
}
