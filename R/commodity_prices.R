world_bank_commodity_prices <- function(source_url, start_year = 1999L) {
  path <- tempfile(fileext = ".xlsx")
  on.exit(unlink(path), add = TRUE)

  httr2::request(source_url) |>
    httr2::req_user_agent("market-sedimentation-coffee/0.2 academic research") |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform(path = path)

  raw <- readxl::read_excel(
    path,
    sheet = "Monthly Prices",
    skip = 4,
    .name_repair = "unique_quiet"
  )
  names(raw)[1] <- "period"
  names(raw) <- janitor::make_clean_names(names(raw))

  candidates <- c("cocoa", "coffee_arabica", "coffee_robusta")
  available <- intersect(candidates, names(raw))
  if (length(available) != length(candidates)) {
    stop(
      "World Bank commodity columns changed. Found: ",
      paste(names(raw), collapse = ", ")
    )
  }

  raw |>
    dplyr::select(period, dplyr::all_of(candidates)) |>
    tidyr::pivot_longer(-period, names_to = "commodity", values_to = "price_usd_kg") |>
    dplyr::mutate(
      period = as.character(period),
      year = suppressWarnings(as.integer(stringr::str_sub(period, 1, 4))),
      month = suppressWarnings(as.integer(stringr::str_sub(period, 6, 7))),
      date = as.Date(sprintf("%04d-%02d-01", year, month)),
      commodity = dplyr::recode(
        commodity,
        cocoa = "Cocoa",
        coffee_arabica = "Coffee, Arabica",
        coffee_robusta = "Coffee, Robusta"
      ),
      price_usd_kg = suppressWarnings(as.numeric(price_usd_kg)),
      source_url = source_url
    ) |>
    dplyr::filter(year >= start_year, !is.na(date), !is.na(price_usd_kg)) |>
    dplyr::select(date, year, month, commodity, price_usd_kg, source_url)
}
