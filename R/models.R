fit_baseline_models <- function(lots) {
  model_data <- lots |>
    dplyr::filter(
      !is.na(final_bid_usd_lb), final_bid_usd_lb > 0,
      !is.na(score), !is.na(weight_lb), weight_lb > 0
    ) |>
    dplyr::mutate(
      log_bid = log(final_bid_usd_lb),
      log_weight = log(weight_lb),
      auction_id = interaction(country, year, program, drop = TRUE)
    )

  if (nrow(model_data) < 30L || dplyr::n_distinct(model_data$auction_id) < 2L) {
    return(list(status = "insufficient_panel", models = list()))
  }

  list(
    status = "estimated",
    models = list(
      baseline = fixest::feols(log_bid ~ splines::ns(score, 3) + log_weight | auction_id, data = model_data),
      attributes = fixest::feols(log_bid ~ splines::ns(score, 3) + log_weight + i(process) + i(variety) | auction_id, data = model_data)
    )
  )
}

