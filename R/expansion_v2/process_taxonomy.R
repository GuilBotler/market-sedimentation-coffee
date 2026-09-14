process_label_status_v2 <- function(process) {
  key <- normalize_key_text(process)
  dplyr::case_when(
    is.na(key) | key == "" ~ "not reported",
    key == "pending" ~ "invalid process label",
    TRUE ~ "reported"
  )
}

canonical_base_process_v2 <- function(process, process_group = NA_character_) {
  detail <- normalize_key_text(process)
  heading <- normalize_key_text(process_group)
  detail_base <- dplyr::case_when(
    stringr::str_detect(detail, "wet hull|giling basah") ~ "Wet hulled",
    stringr::str_detect(
      detail,
      "honey|miel|pulped|depulped|despolpado|descascado|demucilag|semi washed|semi lavado|semiwashed|semil washed"
    ) ~ "Honey / pulped natural",
    stringr::str_detect(detail, "washed|lavado|wash") ~ "Washed",
    stringr::str_detect(detail, "natural|dry|seco|\\bnp\\b") ~ "Natural",
    TRUE ~ NA_character_
  )
  heading_base <- dplyr::case_when(
    stringr::str_detect(heading, "wet hull|giling basah") ~ "Wet hulled",
    stringr::str_detect(heading, "honey|miel|pulped|semi washed") &
      !stringr::str_detect(heading, "natural") ~ "Honey / pulped natural",
    stringr::str_detect(heading, "washed|lavado|wash") &
      !stringr::str_detect(heading, "natural|honey|dry") ~ "Washed",
    stringr::str_detect(heading, "natural|dry|seco") &
      !stringr::str_detect(heading, "honey") ~ "Natural",
    stringr::str_detect(heading, "natural") &
      stringr::str_detect(heading, "honey") ~ "Natural / honey (grouped)",
    TRUE ~ "Not reported"
  )
  dplyr::coalesce(detail_base, heading_base)
}

experimental_method_v2 <- function(process, process_group = NA_character_) {
  combined <- normalize_key_text(paste(process, process_group))
  dplyr::case_when(
    stringr::str_detect(combined, "carbonic|maceration|maceracion|\\bmc\\b") ~
      "Carbonic maceration",
    stringr::str_detect(combined, "double ferment|double anaerob") ~
      "Double fermentation",
    stringr::str_detect(combined, "anaerob") ~ "Anaerobic",
    stringr::str_detect(combined, "macro aerobic|aerobic ferment") ~
      "Aerobic fermentation",
    stringr::str_detect(combined, "lactic|lactico") ~ "Lactic fermentation",
    stringr::str_detect(combined, "mossto|mosto") ~ "Mosto fermentation",
    stringr::str_detect(combined, "yeast|leved") ~ "Yeast fermentation",
    stringr::str_detect(combined, "thermal shock|choque term") ~ "Thermal shock",
    stringr::str_detect(combined, "ferment") ~ "Fermentation unspecified",
    stringr::str_detect(combined, "experimental") ~ "Experimental unspecified",
    TRUE ~ "Conventional"
  )
}

experimental_technology_v2 <- function(base_process, experimental_method) {
  dplyr::if_else(
    experimental_method != "Conventional" & !is.na(experimental_method),
    paste(base_process, experimental_method, sep = " | "),
    NA_character_
  )
}

innovation_class_v2 <- function(process, process_group = NA_character_) {
  status <- process_label_status_v2(process)
  method <- experimental_method_v2(process, process_group)
  base <- canonical_base_process_v2(process, process_group)
  dplyr::case_when(
    status == "invalid process label" ~ "Not reported",
    method != "Conventional" ~ "Experimental",
    base != "Not reported" ~ "Conventional",
    TRUE ~ "Not reported"
  )
}

canonical_process_family_v2 <- function(process, process_group) {
  status <- process_label_status_v2(process)
  base <- canonical_base_process_v2(process, process_group)
  innovation <- innovation_class_v2(process, process_group)
  dplyr::case_when(
    status == "invalid process label" ~ "Not reported",
    innovation == "Experimental" ~ "Experimental",
    base != "Not reported" ~ base,
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
