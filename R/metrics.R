effective_number <- function(x, weights = NULL) {
  keep <- !is.na(x) & x != ""
  if (is.null(weights)) weights <- rep(1, length(x))
  x <- x[keep]
  weights <- weights[keep]
  if (length(x) == 0L || sum(weights, na.rm = TRUE) <= 0) return(NA_real_)
  weights[is.na(weights)] <- 0
  shares <- tapply(weights, x, sum) / sum(weights)
  exp(-sum(shares * log(shares)))
}

differentiation_metrics <- function(lots) {
  entries <- lots |>
    dplyr::group_by(country, year, program, entry_id) |>
    dplyr::summarise(
      process = dplyr::first(process),
      variety = dplyr::first(variety),
      weight_lb = if (all(is.na(weight_lb))) NA_real_ else sum(weight_lb, na.rm = TRUE),
      .groups = "drop"
    )

  lot_outcomes <- lots |>
    dplyr::group_by(country, year, program) |>
    dplyr::summarise(
      auction_lots = dplyr::n(),
      median_bid_usd_lb = if (all(is.na(final_bid_usd_lb))) NA_real_ else median(final_bid_usd_lb, na.rm = TRUE),
      .groups = "drop"
    )

  entries |>
    dplyr::group_by(country, year, program) |>
    dplyr::summarise(
      entries = dplyr::n(),
      effective_processes = effective_number(process),
      effective_varieties = effective_number(variety),
      effective_processes_weighted = effective_number(process, weight_lb),
      .groups = "drop"
    ) |>
    dplyr::left_join(lot_outcomes, by = c("country", "year", "program"))
}
