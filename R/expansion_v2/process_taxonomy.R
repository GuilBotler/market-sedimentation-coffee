canonical_process_family_v2 <- function(process, process_group) {
  detail <- normalize_key_text(process)
  heading <- normalize_key_text(process_group)
  combined <- paste(detail, heading)
  dplyr::case_when(
    stringr::str_detect(combined,
      "experimental|anaerob|ferment|carbonic|maceration|maceracion|thermal shock|yeast") ~ "Experimental",
    stringr::str_detect(detail,
      "honey|miel|pulped|depulped|despolpado|descascado|demucilag|semi washed|semi lavado") ~ "Honey / pulped natural",
    stringr::str_detect(detail, "natural|dry|seco") ~ "Natural",
    stringr::str_detect(detail, "washed|lavado|wet") ~ "Washed",
    stringr::str_detect(heading, "washed|wet|lavado") &
      !stringr::str_detect(heading, "natural|honey|dry") ~ "Washed",
    stringr::str_detect(heading, "natural|dry|seco") &
      !stringr::str_detect(heading, "honey") ~ "Natural",
    stringr::str_detect(heading, "honey") &
      !stringr::str_detect(heading, "natural") ~ "Honey / pulped natural",
    TRUE ~ "Not reported"
  )
}

apply_known_source_corrections <- function(data) {
  data |>
    dplyr::mutate(
      swap_process_variety = country == "Brazil" & year == 2023L & program == "NW" &
        farm %in% c("Sítio da Lagoa", "Fazenda Samambaia"),
      process_original = process, variety_original = variety,
      process = dplyr::if_else(swap_process_variety, variety_original, process_original),
      variety = dplyr::if_else(swap_process_variety, process_original, variety_original)
    ) |>
    dplyr::select(-process_original, -variety_original)
}
