audit_competition <- function(raw, competition) {
  general <- competition |>
    dplyr::summarise(
      entries = dplyr::n(), countries = dplyr::n_distinct(country),
      years = dplyr::n_distinct(year), events = dplyr::n_distinct(paste(country, year)),
      missing_country = sum(is.na(country) | country == ""), missing_year = sum(is.na(year)),
      missing_program = sum(is.na(program) | program == "" | program == "Not classified"),
      missing_rank = sum(is.na(rank) | rank == ""), missing_score = sum(is.na(score)),
      missing_process = sum(process_family == "Not reported")
    )
  coverage <- build_process_coverage(competition)
  duplicates <- competition |>
    dplyr::count(country, year, program, entry_key) |>
    dplyr::filter(n > 1)
  missing_events <- dplyr::anti_join(
    raw |> dplyr::distinct(country, year),
    competition |> dplyr::distinct(country, year), by = c("country", "year")
  )
  invalid_scores <- competition |>
    dplyr::filter(!is.na(score), score < 0 | score > 100)
  suspicious_varieties <- competition |>
    dplyr::filter(!is.na(variety), stringr::str_detect(
      stringr::str_to_lower(variety), "natural|washed|honey|anaerob|ferment"
    ))
  classification <- competition |>
    dplyr::count(process_group, process, process_family, sort = TRUE)
  list(general = general, coverage = coverage, duplicates = duplicates,
       missing_events = missing_events, invalid_scores = invalid_scores,
       suspicious_varieties = suspicious_varieties, classification = classification)
}

write_competition_audit <- function(audit, directory = "data/audit") {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  purrr::iwalk(audit, ~ readr::write_csv(.x, file.path(directory, paste0(.y, ".csv"))))
  invisible(audit)
}
