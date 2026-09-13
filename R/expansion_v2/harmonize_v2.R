event_declared_process_family <- function(event_type, event_name) {
  label <- normalize_key_text(paste(event_type, event_name))
  dplyr::case_when(
    stringr::str_detect(label, "pulped natural") ~ "Honey / pulped natural",
    stringr::str_detect(label, "natural") ~ "Natural",
    TRUE ~ NA_character_
  )
}

identify_sparse_summary_tables_v2 <- function(data, overlap_threshold = 0.8,
                                               minimum_matches = 5L) {
  competition <- data |>
    dplyr::filter(stage == "competition")
  if (nrow(competition) == 0L) {
    return(tibble::tibble(
      event_id = character(), source_table_id = integer(),
      identifiable_rows = integer(), matching_rows = integer(),
      overlap_rate = double()
    ))
  }

  tagged <- competition |>
    dplyr::transmute(
      event_id, source_table_id,
      farm = pick_column(competition, c("farm_cws", "farm_name", "farm")),
      score = ace_number(pick_column(competition, c(
        "score", "cupping_score", "final_score"
      ))),
      process = pick_column(competition, c(
        "process", "processing", "proceso", "processo"
      )),
      variety = pick_column(competition, c(
        "variety", "varietal", "variedad", "variedade"
      ))
    ) |>
    dplyr::mutate(
      farm_key = normalize_key_text(farm),
      identity_key = dplyr::if_else(
        !is.na(farm_key) & farm_key != "" & !is.na(score),
        paste(farm_key, sprintf("%.4f", score), sep = "|"),
        NA_character_
      ),
      has_detail = (!is.na(process) & process != "") |
        (!is.na(variety) & variety != "")
    )

  table_quality <- tagged |>
    dplyr::group_by(event_id, source_table_id) |>
    dplyr::summarise(
      detail_rows = sum(has_detail),
      identifiable_rows = dplyr::n_distinct(identity_key, na.rm = TRUE),
      .groups = "drop"
    )

  rich_identities <- tagged |>
    dplyr::inner_join(
      table_quality |> dplyr::filter(detail_rows > 0L),
      by = c("event_id", "source_table_id")
    ) |>
    dplyr::filter(!is.na(identity_key)) |>
    dplyr::distinct(event_id, identity_key) |>
    dplyr::mutate(found_in_richer_table = TRUE)

  tagged |>
    dplyr::inner_join(
      table_quality |> dplyr::filter(detail_rows == 0L),
      by = c("event_id", "source_table_id")
    ) |>
    dplyr::filter(!is.na(identity_key)) |>
    dplyr::distinct(event_id, source_table_id, identity_key, identifiable_rows) |>
    dplyr::left_join(rich_identities, by = c("event_id", "identity_key")) |>
    dplyr::group_by(event_id, source_table_id, identifiable_rows) |>
    dplyr::summarise(
      matching_rows = sum(found_in_richer_table %in% TRUE),
      overlap_rate = matching_rows / identifiable_rows,
      .groups = "drop"
    ) |>
    dplyr::filter(
      matching_rows >= minimum_matches,
      overlap_rate >= overlap_threshold
    )
}

harmonize_competition_v2 <- function(data) {
  sparse_summaries <- identify_sparse_summary_tables_v2(data)
  data <- data |>
    dplyr::anti_join(
      sparse_summaries |> dplyr::select(event_id, source_table_id),
      by = c("event_id", "source_table_id")
    )

  data |>
    dplyr::transmute(
      event_id, event_name, event_type, country, year = as.integer(year), program,
      process_group,
      rank = as.character(pick_column(data, c("rank", "ranking", "lot", "lot_number", "position"))),
      score = ace_number(pick_column(data, c("score", "cupping_score", "final_score"))),
      farm = pick_column(data, c("farm_cws", "farm_name", "farm")),
      producer = pick_column(data, c("farmer_representative", "farmer", "producer")),
      process = pick_column(data, c("process", "processing", "proceso", "processo")),
      variety = pick_column(data, c("variety", "varietal", "variedad", "variedade")),
      region = pick_column(data, "region"), source_url
    ) |>
    dplyr::mutate(program = tidyr::replace_na(program, "COE")) |>
    apply_known_source_corrections() |>
    dplyr::mutate(
      row_process_family = canonical_process_family_v2(process, process_group),
      declared_process_family = event_declared_process_family(event_type, event_name),
      process_family = dplyr::if_else(
        row_process_family == "Not reported" & !is.na(declared_process_family),
        declared_process_family, row_process_family
      ),
      process_classification_source = dplyr::case_when(
        row_process_family != "Not reported" & !is.na(process) & process != "" ~ "reported process",
        row_process_family != "Not reported" ~ "ACE table heading",
        !is.na(declared_process_family) ~ "ACE event title",
        TRUE ~ "not reported"
      ),
      rank_key = normalize_rank(rank),
      entry_rank = dplyr::if_else(
        program == "COE" & stringr::str_detect(rank_key, "^[0-9]+[AB]$"),
        stringr::str_remove(rank_key, "[AB]$"), rank_key
      ),
      farm_key = normalize_key_text(farm), producer_key = normalize_key_text(producer),
      entry_key = dplyr::case_when(
        program == "NW" ~ paste(event_id, program, farm_key, producer_key,
                                sprintf("%.2f", score), sep = "|"),
        TRUE ~ paste(event_id, program, process_group, entry_rank, sep = "|")
      )
    ) |>
    dplyr::distinct(event_id, program, entry_key, .keep_all = TRUE) |>
    dplyr::select(-row_process_family, -declared_process_family)
}

harmonize_auction_v2 <- function(data) {
  data |>
    dplyr::transmute(
      event_id, event_name, event_type, country, year = as.integer(year), program,
      process_group,
      rank = as.character(pick_column(data, c("rank", "ranking", "lot", "lot_number", "position"))),
      score = ace_number(pick_column(data, c("score", "cupping_score", "final_score"))),
      farm = pick_column(data, c("farm_cws", "farm_name", "farm")),
      variety = pick_column(data, c("variety", "varietal", "variedad", "variedade")),
      weight_lb = ace_number(pick_column(data, c("weight_lb", "weight_lbs", "weight", "size"))),
      final_bid_usd_lb = ace_number(pick_column(data, c(
        "final_bid_lb", "final_bid_usd_lb", "price_per_lb", "price_lb", "high_bid", "winning_bid"
      ))),
      total_value_usd = ace_number(pick_column(data, c("total_value", "total_price", "value"))),
      buyer = pick_column(data, c("company_name", "buyer", "winner", "winning_bidder")),
      source_url
    ) |>
    dplyr::mutate(
      program = tidyr::replace_na(program, "COE"),
      rank_key = normalize_rank(rank),
      lot_key = paste(event_id, program, process_group, rank_key, sep = "|")
    ) |>
    dplyr::distinct(event_id, program, lot_key, .keep_all = TRUE)
}
