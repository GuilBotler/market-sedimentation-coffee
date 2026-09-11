collect_ace_registry <- function(registry, user_agent) {
  results <- purrr::pmap(
    registry |> dplyr::select(country, year, source_url),
    function(country, year, source_url) {
      started <- Sys.time()
      tryCatch(
        {
          raw <- scrape_ace_event(country, year, source_url, user_agent)
          lots <- harmonize_ace_tables(raw)
          list(
            data = lots,
            audit = tibble::tibble(
              country = country,
              year = as.integer(year),
              source_url = source_url,
              status = "included",
              auction_lots = nrow(lots),
              coffee_entries = dplyr::n_distinct(lots$entry_id),
              reported_bids = sum(!is.na(lots$final_bid_usd_lb)),
              message = NA_character_,
              elapsed_seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))
            )
          )
        },
        error = function(error) {
          list(
            data = tibble::tibble(),
            audit = tibble::tibble(
              country = country,
              year = as.integer(year),
              source_url = source_url,
              status = "excluded",
              auction_lots = 0L,
              coffee_entries = 0L,
              reported_bids = 0L,
              message = conditionMessage(error),
              elapsed_seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))
            )
          )
        }
      )
    }
  )

  data <- purrr::map_dfr(results, "data")
  audit <- purrr::map_dfr(results, "audit")
  if (nrow(data) == 0L) stop("No ACE event passed the validation contract.")

  list(data = data, audit = audit)
}
