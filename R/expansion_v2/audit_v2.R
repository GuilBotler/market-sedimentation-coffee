build_v2_audit <- function(raw, competition, auction, process_coverage, process_shares) {
  raw_competition_counts <- raw |>
    dplyr::filter(download_status == "success", stage == "competition") |>
    dplyr::count(event_id, country, year, event_name, name = "raw_rows")

  clean_competition_counts <- competition |>
    dplyr::count(event_id, country, year, event_name, name = "entries")

  list(
    download = raw |>
      dplyr::group_by(event_id, country, year, event_name, event_type, source_url,
                      download_status, download_error) |>
      dplyr::summarise(
        competition_rows = sum(stage == "competition", na.rm = TRUE),
        auction_rows = sum(stage == "auction", na.rm = TRUE), .groups = "drop"
      ),
    process_coverage = process_coverage,
    sparse_summary_tables = identify_sparse_summary_tables_v2(raw),
    entry_reduction = dplyr::full_join(
      raw_competition_counts,
      clean_competition_counts,
      by = c("event_id", "country", "year", "event_name")
    ) |>
      dplyr::mutate(
        raw_rows = tidyr::replace_na(raw_rows, 0L),
        entries = tidyr::replace_na(entries, 0L),
        removed = raw_rows - entries,
        retention_rate = dplyr::if_else(raw_rows > 0L, entries / raw_rows, NA_real_)
      ) |>
      dplyr::arrange(dplyr::desc(abs(removed)), country, year, event_name),
    duplicate_entries = competition |>
      dplyr::count(event_id, program, entry_key) |> dplyr::filter(n > 1),
    duplicate_lots = auction |>
      dplyr::count(event_id, program, lot_key) |> dplyr::filter(n > 1),
    invalid_scores = competition |>
      dplyr::filter(!is.na(score), score < 0 | score > 100),
    suspicious_varieties = competition |>
      dplyr::filter(!is.na(variety), stringr::str_detect(
        stringr::str_to_lower(variety), "natural|washed|honey|anaerob|ferment"
      )),
    share_sums = process_shares |>
      dplyr::group_by(event_id, country, year, program) |>
      dplyr::summarise(
        share_all_sum = sum(share_all),
        share_reported_sum = sum(share_reported, na.rm = TRUE),
        coverage_rate = dplyr::first(coverage_rate), .groups = "drop"
      ),
    process_by_year = competition |>
      dplyr::group_by(year) |>
      dplyr::summarise(
        entries = dplyr::n(), reported = sum(process_family != "Not reported"),
        missing = sum(process_family == "Not reported"),
        coverage = reported / entries, .groups = "drop"
      )
  )
}

write_v2_audit <- function(audit, directory = "data/audit/v2") {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  purrr::iwalk(audit, ~ readr::write_csv(.x, file.path(directory, paste0(.y, ".csv"))))
  invisible(audit)
}
