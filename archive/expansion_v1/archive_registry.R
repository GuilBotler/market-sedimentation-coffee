ace_country_dictionary <- function() {
  tibble::tribble(
    ~country, ~slug_key,
    "Bolivia", "bolivia", "Brazil", "brazil", "Burundi", "burundi",
    "Colombia", "colombia", "Costa Rica", "costa-rica", "Ecuador", "ecuador",
    "El Salvador", "el-salvador", "Ethiopia", "ethiopia", "Guatemala", "guatemala",
    "Honduras", "honduras", "Indonesia", "indonesia", "Mexico", "mexico",
    "Nicaragua", "nicaragua", "Panama", "panama", "Peru", "peru",
    "Rwanda", "rwanda", "Thailand", "thailand", "Taiwan", "taiwan"
  )
}

identify_ace_country <- function(slug, dictionary = ace_country_dictionary()) {
  hit <- dictionary |>
    dplyr::filter(stringr::str_detect(slug, paste0("^", slug_key, "(-|$)")))
  if (nrow(hit) == 0L) return(NA_character_)
  hit$country[[1]]
}

discover_ace_archive <- function(start_year = 1999L, end_year = 2019L,
                                 archive_url = "https://allianceforcoffeeexcellence.org/competition-auction-results/") {
  page <- xml2::read_html(archive_url)
  nodes <- rvest::html_elements(page, "a")
  links <- tibble::tibble(
    link_text = rvest::html_text2(nodes),
    href = rvest::html_attr(nodes, "href")
  ) |>
    dplyr::filter(!is.na(href)) |>
    dplyr::mutate(
      source_url = xml2::url_absolute(href, archive_url),
      slug = source_url |> stringr::str_remove("/$") |> basename() |> stringr::str_to_lower(),
      year = suppressWarnings(as.integer(stringr::str_extract(
        paste(link_text, slug), "(19|20)[0-9]{2}"
      )))
    ) |>
    dplyr::filter(
      !is.na(year), year >= start_year, year <= end_year,
      stringr::str_detect(source_url, "allianceforcoffeeexcellence.org")
    ) |>
    dplyr::distinct(source_url, .keep_all = TRUE)

  links |>
    dplyr::mutate(
      country = purrr::map_chr(slug, identify_ace_country),
      event_name = dplyr::if_else(is.na(link_text) | link_text == "", slug, link_text),
      event_type = dplyr::case_when(
        stringr::str_detect(slug, "pulped-natural") ~ "COE Pulped Natural",
        stringr::str_detect(slug, "natural") ~ "COE Natural",
        stringr::str_detect(slug, "north|south") ~ "COE regional",
        TRUE ~ "COE"
      ),
      accessed_at = Sys.Date(), active = TRUE,
      notes = "Official ACE historical results page"
    ) |>
    dplyr::select(country, year, event_name, event_type, source_url,
                  accessed_at, active, notes) |>
    dplyr::arrange(country, year, source_url)
}

combine_source_registries <- function(current, historical) {
  normalize <- function(x) x |>
    dplyr::mutate(
      year = as.integer(year), accessed_at = as.Date(accessed_at),
      active = as.logical(active)
    )
  dplyr::bind_rows(normalize(current), normalize(historical)) |>
    dplyr::distinct(source_url, .keep_all = TRUE) |>
    dplyr::arrange(country, year, source_url)
}
