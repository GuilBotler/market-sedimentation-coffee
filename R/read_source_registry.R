read_source_registry <- function(path) {
  readr::read_csv(path, show_col_types = FALSE) |>
    dplyr::mutate(
      year = as.integer(year),
      accessed_at = as.Date(accessed_at),
      active = as.logical(active)
    ) |>
    dplyr::filter(active)
}

