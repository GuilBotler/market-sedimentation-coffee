build_entry_lot_matches_v2 <- function(entries, lots) {
  entry_lookup <- entries |>
    dplyr::mutate(
      process_group_key = dplyr::na_if(normalize_key_text(process_group), "")
    )

  exact_lookup <- entry_lookup |>
    dplyr::group_by(event_id, program, process_group_key, entry_rank) |>
    dplyr::summarise(
      exact_candidates = dplyr::n_distinct(entry_key),
      exact_entry_key = dplyr::if_else(
        exact_candidates == 1L, dplyr::first(entry_key), NA_character_
      ),
      .groups = "drop"
    )

  rank_lookup <- entry_lookup |>
    dplyr::group_by(event_id, program, entry_rank) |>
    dplyr::summarise(
      rank_candidates = dplyr::n_distinct(entry_key),
      rank_entry_key = dplyr::if_else(
        rank_candidates == 1L, dplyr::first(entry_key), NA_character_
      ),
      .groups = "drop"
    )

  entry_programs <- entries |>
    dplyr::distinct(event_id, program) |>
    dplyr::mutate(has_competition_program = TRUE)

  entry_events <- entries |>
    dplyr::distinct(event_id) |>
    dplyr::mutate(has_competition_event = TRUE)

  lots |>
    dplyr::mutate(
      process_group_key = dplyr::na_if(normalize_key_text(process_group), "")
    ) |>
    dplyr::left_join(
      exact_lookup,
      by = c("event_id", "program", "process_group_key", "entry_rank")
    ) |>
    dplyr::left_join(
      rank_lookup,
      by = c("event_id", "program", "entry_rank")
    ) |>
    dplyr::left_join(
      entry_programs,
      by = c("event_id", "program")
    ) |>
    dplyr::left_join(entry_events, by = "event_id") |>
    dplyr::mutate(
      exact_candidates = tidyr::replace_na(exact_candidates, 0L),
      rank_candidates = tidyr::replace_na(rank_candidates, 0L),
      entry_key = dplyr::coalesce(exact_entry_key, rank_entry_key),
      match_status = dplyr::case_when(
        exact_candidates == 1L ~ "matched: process group and rank",
        rank_candidates == 1L ~ "matched: unique event rank",
        exact_candidates > 1L | rank_candidates > 1L ~ "ambiguous entry rank",
        TRUE ~ "no competition entry"
      ),
      unmatched_reason = dplyr::case_when(
        match_status != "no competition entry" ~ NA_character_,
        has_competition_program %in% TRUE ~
          "rank outside reported competition table",
        has_competition_event %in% TRUE ~
          "auction program without competition table",
        TRUE ~ "auction event without competition table"
      )
    ) |>
    dplyr::select(
      event_id, country, year, program, process_group, rank, rank_key,
      entry_rank, lot_key, entry_key, match_status, unmatched_reason, exact_candidates,
      rank_candidates, final_bid_usd_lb, weight_lb, total_value_usd, buyer,
      source_url
    )
}

build_auction_audit_v2 <- function(entries, lots) {
  matches <- build_entry_lot_matches_v2(entries, lots)

  event_coverage <- lots |>
    dplyr::group_by(event_id, country, year, program, event_name, source_url) |>
    dplyr::summarise(
      lots = dplyr::n(),
      prices_reported = sum(is.finite(final_bid_usd_lb) & final_bid_usd_lb > 0),
      weights_reported = sum(is.finite(weight_lb) & weight_lb > 0),
      buyers_reported = sum(!is.na(buyer) & trimws(buyer) != ""),
      price_coverage = prices_reported / lots,
      weight_coverage = weights_reported / lots,
      buyer_coverage = buyers_reported / lots,
      .groups = "drop"
    )

  price_audit <- lots |>
    dplyr::mutate(
      valid_price = is.finite(final_bid_usd_lb) & final_bid_usd_lb > 0,
      comparable_value = valid_price & is.finite(weight_lb) & weight_lb > 0 &
        is.finite(total_value_usd) & total_value_usd > 0,
      calculated_value_usd = dplyr::if_else(
        comparable_value, final_bid_usd_lb * weight_lb, NA_real_
      ),
      relative_value_difference = dplyr::if_else(
        comparable_value,
        abs(total_value_usd - calculated_value_usd) / total_value_usd,
        NA_real_
      )
    ) |>
    dplyr::select(
      event_id, country, year, program, rank, lot_key, valid_price,
      final_bid_usd_lb, weight_lb, total_value_usd, calculated_value_usd,
      relative_value_difference, source_url
    )

  buyer_audit <- lots |>
    dplyr::group_by(event_id, country, year, program, event_name, source_url) |>
    dplyr::summarise(
      lots = dplyr::n(),
      buyer_labels_reported = sum(!is.na(buyer) & trimws(buyer) != ""),
      distinct_buyer_labels = dplyr::n_distinct(
        buyer[!is.na(buyer) & trimws(buyer) != ""]
      ),
      buyer_coverage = buyer_labels_reported / lots,
      .groups = "drop"
    )

  matching_audit <- matches |>
    dplyr::count(
      event_id, country, year, program, match_status, unmatched_reason,
      name = "lots"
    ) |>
    dplyr::group_by(event_id, country, year, program) |>
    dplyr::mutate(
      event_lots = sum(lots),
      share_of_event_lots = lots / event_lots
    ) |>
    dplyr::ungroup()

  list(
    auction_event_coverage = event_coverage,
    auction_price_audit = price_audit,
    auction_buyer_audit = buyer_audit,
    entry_lot_matches = matches,
    entry_lot_matching_audit = matching_audit
  )
}

write_auction_audit_v2 <- function(audit, directory = "data/audit/v2") {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  purrr::iwalk(
    audit,
    ~ readr::write_csv(.x, file.path(directory, paste0(.y, ".csv")))
  )
  invisible(audit)
}
