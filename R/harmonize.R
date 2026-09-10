pick_column <- function(data, candidates, default = NA_character_) {
  hit <- intersect(candidates, names(data))
  if (length(hit) == 0L) return(rep(default, nrow(data)))
  data[[hit[[1]]]]
}

normalize_key_text <- function(x) {
  x |>
    stringi::stri_trans_general("Latin-ASCII") |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^a-z0-9]+", " ") |>
    stringr::str_squish()
}

harmonize_ace_tables <- function(raw_tables) {
  competition <- raw_tables |>
    dplyr::filter(stage == "competition") |>
    dplyr::transmute(
      country, year, program, process_group,
      rank = as.character(pick_column(dplyr::cur_data(), c("rank"))),
      score = ace_number(pick_column(dplyr::cur_data(), c("score"))),
      farm = pick_column(dplyr::cur_data(), c("farm_cws", "farm")),
      producer = pick_column(dplyr::cur_data(), c("farmer_representative", "producer")),
      process = pick_column(dplyr::cur_data(), c("process")),
      variety = pick_column(dplyr::cur_data(), c("variety")),
      region = pick_column(dplyr::cur_data(), c("region")),
      source_url,
      observed_competition = TRUE
    )

  auction <- raw_tables |>
    dplyr::filter(stage == "auction") |>
    dplyr::transmute(
      country, year, program, process_group,
      rank = as.character(pick_column(dplyr::cur_data(), c("rank"))),
      score = ace_number(pick_column(dplyr::cur_data(), c("score"))),
      farm = pick_column(dplyr::cur_data(), c("farm_cws", "farm")),
      variety = pick_column(dplyr::cur_data(), c("variety")),
      weight_lb = ace_number(pick_column(dplyr::cur_data(), c("weight_lb", "weight_lbs"))),
      final_bid_usd_lb = ace_number(pick_column(dplyr::cur_data(), c("final_bid_lb", "final_bid_usd_lb"))),
      total_value_usd = ace_number(pick_column(dplyr::cur_data(), c("total_value"))),
      buyer = pick_column(dplyr::cur_data(), c("company_name", "buyer")),
      source_url,
      observed_auction = TRUE
    )

  key_vars <- c("country", "year", "program", "process_group", "rank")
  duplicates <- dplyr::bind_rows(
    competition |> dplyr::count(dplyr::across(dplyr::all_of(key_vars))) |> dplyr::filter(n > 1),
    auction |> dplyr::count(dplyr::across(dplyr::all_of(key_vars))) |> dplyr::filter(n > 1)
  )
  if (nrow(duplicates) > 0L) stop("Non-unique lot keys require manual review.")

  joined <- dplyr::full_join(
    competition,
    auction,
    by = key_vars,
    suffix = c("_competition", "_auction")
  ) |>
    dplyr::mutate(
      score = dplyr::coalesce(score_competition, score_auction),
      farm = dplyr::coalesce(farm_competition, farm_auction),
      variety = dplyr::coalesce(variety_competition, variety_auction),
      source_url = dplyr::coalesce(source_url_competition, source_url_auction),
      lot_id = purrr::pmap_chr(
        list(country, year, program, process_group, rank, farm),
        function(country, year, program, process_group, rank, farm) {
          digest::digest(
            paste(country, year, program, process_group, rank, farm, sep = "|"),
            algo = "xxhash64"
          )
        }
      )
    ) |>
    dplyr::select(
      lot_id, country, year, program, process_group, rank, score, farm,
      producer, process, variety, region, weight_lb, final_bid_usd_lb,
      total_value_usd, buyer, observed_competition, observed_auction, source_url
    )

  unmatched <- joined |>
    dplyr::filter(is.na(observed_competition) | is.na(observed_auction))
  if (nrow(unmatched) > 0L) stop("Competition-to-auction joins are incomplete; review lot keys.")

  required_missing <- joined |>
    dplyr::filter(
      is.na(country) | is.na(year) | is.na(program) | is.na(rank) |
        is.na(score) | is.na(source_url)
    )
  if (nrow(required_missing) > 0L) stop("Required lot fields are missing; review table classification.")

  if (any(joined$score < 0 | joined$score > 100, na.rm = TRUE)) {
    stop("Scores outside 0–100 indicate a parsing error.")
  }

  bad_value <- joined |>
    dplyr::filter(
      !is.na(total_value_usd), !is.na(weight_lb), !is.na(final_bid_usd_lb),
      abs(total_value_usd - weight_lb * final_bid_usd_lb) > 2
    )
  if (nrow(bad_value) > 0L) stop("Published total and weight × bid disagree; review parsing.")

  joined
}
