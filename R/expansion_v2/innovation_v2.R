build_process_taxonomy_audit_v2 <- function(entries, start_year = 2018L) {
  entries |>
    dplyr::filter(program == "COE", year >= start_year) |>
    dplyr::count(
      process_group, process, process_label_status,
      process_classification_source, process_family, base_process,
      innovation_class, experimental_method,
      name = "entries"
    ) |>
    dplyr::arrange(
      dplyr::desc(entries), innovation_class, base_process, process
    )
}

build_innovation_entries_v2 <- function(entries, start_year = 2018L) {
  analysis_entries <- entries |>
    dplyr::filter(
      program == "COE",
      year >= start_year,
      process_classification_source == "reported process"
    ) |>
    dplyr::mutate(
      experimental_technology = experimental_technology_v2(
        base_process, experimental_method
      )
    )

  appearances <- analysis_entries |>
    dplyr::filter(innovation_class == "Experimental") |>
    dplyr::group_by(country, experimental_technology) |>
    dplyr::summarise(
      first_observed_year_country = min(year),
      last_observed_year_country = max(year),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      left_censored_at_baseline = first_observed_year_country == start_year,
      appearance_after_baseline = first_observed_year_country > start_year,
      observed_again_later = last_observed_year_country >
        first_observed_year_country
    )

  analysis_entries |>
    dplyr::left_join(
      appearances,
      by = c("country", "experimental_technology")
    ) |>
    dplyr::mutate(
      first_observed_experimental_entry =
        innovation_class == "Experimental" &
        appearance_after_baseline %in% TRUE &
        year == first_observed_year_country,
      reproduced_experimental_entry =
        innovation_class == "Experimental" &
        !is.na(first_observed_year_country) &
        year > first_observed_year_country
    ) |>
    dplyr::arrange(country, year, entry_rank)
}

build_innovation_country_year_v2 <- function(innovation_entries) {
  innovation_entries |>
    dplyr::group_by(country, year) |>
    dplyr::summarise(
      entries = dplyr::n(),
      experimental_entries = sum(innovation_class == "Experimental"),
      experimental_share = experimental_entries / entries,
      experimental_technologies = dplyr::n_distinct(
        experimental_technology[innovation_class == "Experimental"],
        na.rm = TRUE
      ),
      new_experimental_technologies = dplyr::n_distinct(
        experimental_technology[first_observed_experimental_entry %in% TRUE],
        na.rm = TRUE
      ),
      reproduced_experimental_entries = sum(
        reproduced_experimental_entry %in% TRUE
      ),
      .groups = "drop"
    ) |>
    dplyr::arrange(country, year)
}

build_base_process_country_year_v2 <- function(innovation_entries) {
  innovation_entries |>
    dplyr::count(country, year, base_process, name = "entries") |>
    dplyr::group_by(country, year) |>
    dplyr::mutate(
      total_entries = sum(entries),
      share = entries / total_entries
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(country, year, base_process)
}

build_innovation_sample_summary_v2 <- function(entries, innovation_entries,
                                                innovation_remuneration) {
  eligible <- entries |>
    dplyr::filter(program == "COE", year >= 2018L)

  tibble::tibble(
    measure = c(
      "COE entries from 2018",
      "valid directly reported processes",
      "invalid process labels",
      "process not reported",
      "conventional entries in innovation panel",
      "experimental entries in innovation panel",
      "experimental entries with unknown base process",
      "innovation entries matched to a valid auction price"
    ),
    value = c(
      nrow(eligible),
      nrow(innovation_entries),
      sum(eligible$process_label_status == "invalid process label"),
      sum(eligible$process_label_status == "not reported"),
      sum(innovation_entries$innovation_class == "Conventional"),
      sum(innovation_entries$innovation_class == "Experimental"),
      sum(
        innovation_entries$innovation_class == "Experimental" &
          innovation_entries$base_process == "Not reported"
      ),
      nrow(innovation_remuneration)
    )
  )
}

build_innovation_remuneration_v2 <- function(entry_lot_panel,
                                              innovation_entries) {
  innovation_fields <- innovation_entries |>
    dplyr::select(
      event_id, program, entry_key, process_label_status, base_process,
      innovation_class, experimental_method, experimental_technology,
      first_observed_year_country, last_observed_year_country,
      left_censored_at_baseline, appearance_after_baseline,
      first_observed_experimental_entry, reproduced_experimental_entry
    )

  entry_lot_panel |>
    dplyr::select(
      -dplyr::any_of(c(
        "process_label_status", "base_process", "innovation_class",
        "experimental_method", "experimental_technology",
        "first_observed_year_country", "last_observed_year_country",
        "left_censored_at_baseline", "appearance_after_baseline",
        "first_observed_experimental_entry",
        "reproduced_experimental_entry"
      ))
    ) |>
    dplyr::inner_join(
      innovation_fields,
      by = c("event_id", "program", "entry_key")
    ) |>
    dplyr::filter(eligible_matched_price_sample %in% TRUE) |>
    dplyr::arrange(country, year, entry_rank)
}
