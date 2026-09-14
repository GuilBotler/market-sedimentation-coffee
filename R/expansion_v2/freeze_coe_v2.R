build_frozen_auction_lots_v2 <- function(lots, matches) {
  match_fields <- matches |>
    dplyr::select(
      lot_key, entry_key, match_status, unmatched_reason
    )

  lots |>
    dplyr::left_join(match_fields, by = "lot_key") |>
    dplyr::mutate(
      price_reported = is.finite(final_bid_usd_lb) & final_bid_usd_lb > 0,
      weight_reported = is.finite(weight_lb) & weight_lb > 0,
      buyer_reported = !is.na(buyer) & trimws(buyer) != "",
      value_reported = is.finite(total_value_usd) & total_value_usd > 0,
      calculated_value_usd = dplyr::if_else(
        price_reported & weight_reported,
        final_bid_usd_lb * weight_lb,
        NA_real_
      ),
      relative_value_difference = dplyr::if_else(
        price_reported & weight_reported & value_reported,
        abs(total_value_usd - calculated_value_usd) / total_value_usd,
        NA_real_
      ),
      value_identity_status = dplyr::case_when(
        is.na(relative_value_difference) ~ "not testable",
        relative_value_difference <= 0.02 ~ "consistent within 2 percent",
        TRUE ~ "inconsistent"
      ),
      eligible_matched_price_sample = match_status %in% c(
        "matched: process group and rank",
        "matched: unique event rank"
      ) & price_reported
    )
}

build_entry_lot_panel_v2 <- function(entries, frozen_lots) {
  auction_fields <- frozen_lots |>
    dplyr::filter(!is.na(entry_key)) |>
    dplyr::select(
      event_id, program, entry_key, lot_key, auction_rank = rank,
      final_bid_usd_lb, weight_lb, total_value_usd, buyer,
      price_reported, weight_reported, buyer_reported, value_reported,
      calculated_value_usd, relative_value_difference,
      value_identity_status, match_status, unmatched_reason,
      eligible_matched_price_sample
    )

  entries |>
    dplyr::inner_join(
      auction_fields,
      by = c("event_id", "program", "entry_key")
    ) |>
    dplyr::arrange(country, year, program, entry_rank, auction_rank)
}

build_freeze_summary_v2 <- function(entries, frozen_lots, entry_lot_panel) {
  tibble::tibble(
    measure = c(
      "competition entries",
      "auction lots",
      "auction lots with price",
      "auction lots with buyer",
      "automatically matched auction lots",
      "matched auction lots with price",
      "unique competition entries represented in matched panel",
      "ambiguous auction lots",
      "rank outside reported competition table",
      "auction program without competition table",
      "auction event without competition table",
      "inconsistent price-weight-value identities"
    ),
    value = c(
      nrow(entries),
      nrow(frozen_lots),
      sum(frozen_lots$price_reported),
      sum(frozen_lots$buyer_reported),
      sum(!is.na(frozen_lots$entry_key)),
      sum(frozen_lots$eligible_matched_price_sample),
      dplyr::n_distinct(entry_lot_panel$entry_key),
      sum(frozen_lots$match_status == "ambiguous entry rank"),
      sum(frozen_lots$unmatched_reason ==
            "rank outside reported competition table", na.rm = TRUE),
      sum(frozen_lots$unmatched_reason ==
            "auction program without competition table", na.rm = TRUE),
      sum(frozen_lots$unmatched_reason ==
            "auction event without competition table", na.rm = TRUE),
      sum(frozen_lots$value_identity_status == "inconsistent")
    )
  )
}
