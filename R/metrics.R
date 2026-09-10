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
  lots |>
    dplyr::group_by(country, year, program) |>
    dplyr::summarise(
      lots = dplyr::n(),
      effective_processes = effective_number(process),
      effective_varieties = effective_number(variety),
      effective_processes_weighted = effective_number(process, weight_lb),
      median_bid_usd_lb = median(final_bid_usd_lb, na.rm = TRUE),
      .groups = "drop"
    )
}
