harmonize_competition_only <- function(data) {
  data |>
    dplyr::transmute(
      country, year, program, process_group,
      rank = as.character(pick_column(data, c("rank", "ranking"))),
      score = ace_number(pick_column(data, "score")),
      farm = pick_column(data, c("farm_cws", "farm_name", "farm")),
      producer = pick_column(data, c("farmer_representative", "farmer", "producer")),
      process = pick_column(data, c("process", "processing", "proceso", "processo")),
      variety = pick_column(data, c("variety", "varietal", "variedad", "variedade")),
      region = pick_column(data, "region"), source_url
    ) |>
    dplyr::mutate(program = tidyr::replace_na(program, "Not classified")) |>
    apply_known_source_corrections() |>
    dplyr::mutate(
      process_family = canonical_process_family_v2(process, process_group),
      rank_key = normalize_rank(rank),
      entry_rank = dplyr::if_else(
        program == "COE" & stringr::str_detect(rank_key, "^[0-9]+[AB]$"),
        stringr::str_remove(rank_key, "[AB]$"), rank_key
      ),
      farm_key = normalize_key_text(farm),
      producer_key = normalize_key_text(producer),
      entry_key = dplyr::case_when(
        program == "NW" ~ paste(country, year, program, farm_key, producer_key,
                                sprintf("%.2f", score), sep = "|"),
        TRUE ~ paste(country, year, program, process_group, entry_rank, sep = "|")
      )
    ) |>
    dplyr::distinct(country, year, program, entry_key, .keep_all = TRUE)
}
