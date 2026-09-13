build_process_coverage_v2 <- function(competition) {
  competition |>
    dplyr::group_by(event_id, event_name, event_type, country, year, program) |>
    dplyr::summarise(
      entries = dplyr::n(), reported_process = sum(process_family != "Not reported"),
      missing_process = sum(process_family == "Not reported"),
      coverage_rate = reported_process / entries, .groups = "drop"
    )
}

build_process_shares_v2 <- function(competition) {
  competition |>
    dplyr::count(event_id, event_name, event_type, country, year, program,
                 process_family, name = "entries") |>
    dplyr::group_by(event_id, country, year, program) |>
    dplyr::mutate(
      total_entries = sum(entries),
      reported_entries = sum(entries[process_family != "Not reported"]),
      share_all = entries / total_entries,
      share_reported = dplyr::if_else(
        process_family != "Not reported" & reported_entries > 0,
        entries / reported_entries, NA_real_
      ),
      coverage_rate = reported_entries / total_entries
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(country, year, event_id, program, process_family)
}

aggregate_country_year_process <- function(event_shares) {
  event_shares |>
    dplyr::group_by(country, year, program, process_family) |>
    dplyr::summarise(entries = sum(entries), .groups = "drop_last") |>
    dplyr::mutate(
      total_entries = sum(entries), share_all = entries / total_entries
    ) |>
    dplyr::ungroup()
}
