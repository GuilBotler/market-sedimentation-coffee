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
    tidyr::pivot_longer(-period, names_to = "series", values_to = "value") |>
    dplyr::mutate(
      period = as.character(period),
      year = suppressWarnings(as.integer(stringr::str_sub(period, 1, 4))),
      month = suppressWarnings(as.integer(stringr::str_sub(period, 6, 7)))
    ) |>
    dplyr::filter(
      !is.na(year),
      dplyr::between(month, 1L, 12L),
      year >= start_year
    ) |>
    dplyr::mutate(
      date = as.Date(sprintf("%04d-%02d-01", year, month)),
      series = dplyr::recode(
        series,
        cocoa = "Cocoa — World Bank",
        coffee_arabica = "Coffee Arabica — World Bank",
        coffee_robusta = "Coffee Robusta — World Bank"
      ),
      value = suppressWarnings(as.numeric(value)),
      unit = "USD/kg",
      market_scope = "Global commodity benchmark",
      source_url = source_url
    ) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::select(date, year, month, series, value, unit, market_scope, source_url)
}

fred_wine_price_index <- function(source_url, start_year = 1999L) {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)

  httr2::request(source_url) |>
    httr2::req_user_agent("market-sedimentation-coffee/0.2 academic research") |>
    httr2::req_options(http_version = 2L) |>
    httr2::req_retry(max_tries = 5, retry_on_failure = TRUE) |>
    httr2::req_perform(path = path)

  raw <- readr::read_csv(path, show_col_types = FALSE, na = c(".", "NA")) |>
    janitor::clean_names()
  date_column <- intersect(c("observation_date", "date"), names(raw))
  value_column <- intersect(c("pcu3121303121300"), names(raw))
  if (length(date_column) != 1L || length(value_column) != 1L) {
    stop(
      "FRED wine index columns changed. Found: ",
      paste(names(raw), collapse = ", ")
    )
  }

  raw |>
    dplyr::transmute(
      date = as.Date(.data[[date_column]]),
      year = as.integer(format(date, "%Y")),
      month = as.integer(format(date, "%m")),
      series = "Wine & brandy — US winery PPI",
      value = suppressWarnings(as.numeric(.data[[value_column]])),
      unit = "Index (Dec 1998=100)",
      market_scope = "United States producer price index",
      source_url = source_url
    ) |>
    dplyr::filter(year >= start_year, !is.na(date), !is.na(value))
}

collect_market_benchmarks <- function(world_bank_url, fred_wine_url, start_year = 1999L) {
  dplyr::bind_rows(
    world_bank_commodity_prices(world_bank_url, start_year),
    fred_wine_price_index(fred_wine_url, start_year)
  ) |>
    dplyr::arrange(series, date)
}
