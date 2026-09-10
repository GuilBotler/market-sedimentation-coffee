ace_number <- function(x) {
  x <- stringr::str_squish(as.character(x))
  x[x == ""] <- NA_character_
  clean_one <- function(value) {
    if (is.na(value)) return(NA_real_)
    z <- stringr::str_replace_all(value, "[^0-9,.-]", "")
    has_comma <- stringr::str_detect(z, ",")
    has_dot <- stringr::str_detect(z, "\\.")
    if (has_comma && has_dot) {
      comma_last <- max(gregexpr(",", z, fixed = TRUE)[[1]])
      dot_last <- max(gregexpr(".", z, fixed = TRUE)[[1]])
      if (comma_last > dot_last) {
        z <- stringr::str_replace_all(z, stringr::fixed("."), "")
        z <- stringr::str_replace(z, stringr::fixed(","), ".")
      } else {
        z <- stringr::str_replace_all(z, stringr::fixed(","), "")
      }
    } else if (has_comma) {
      digits_after <- nchar(z) - stringr::str_locate(z, ",")[1, 1]
      z <- if (digits_after <= 2L) stringr::str_replace(z, stringr::fixed(","), ".") else stringr::str_replace_all(z, stringr::fixed(","), "")
    }
    suppressWarnings(as.numeric(z))
  }
  unname(vapply(x, clean_one, numeric(1)))
}

nearest_heading <- function(node, level) {
  xpath <- sprintf("preceding::%s[1]", level)
  heading <- rvest::html_element(node, xpath = xpath)
  ifelse(is.na(heading), NA_character_, rvest::html_text2(heading))
}

classify_program <- function(section_heading) {
  dplyr::case_when(
    stringr::str_detect(section_heading, regex("National|NW", ignore_case = TRUE)) ~ "NW",
    stringr::str_detect(section_heading, regex("COE|Cup of Excellence", ignore_case = TRUE)) ~ "COE",
    TRUE ~ NA_character_
  )
}

standardize_ace_table <- function(table_node, table_id, country, year, source_url) {
  section <- nearest_heading(table_node, "h4")
  process_group <- nearest_heading(table_node, "h2")
  program <- classify_program(section)
  raw <- rvest::html_table(table_node, header = FALSE, fill = TRUE, trim = TRUE)
  if (nrow(raw) < 2L) return(tibble::tibble())

  headers <- as.character(unlist(raw[1, ], use.names = FALSE))
  out <- raw[-1, , drop = FALSE]
  names(out) <- janitor::make_clean_names(headers)

  names_upper <- toupper(names(out))
  if (!"SCORE" %in% names_upper) return(tibble::tibble())
  if (!any(c("RANK", "RANKING") %in% names_upper)) {
    if (identical(program, "NW")) {
      out$rank <- "NW"
      names_upper <- toupper(names(out))
    } else {
      return(tibble::tibble())
    }
  }
  stage <- if (any(stringr::str_detect(
    names_upper,
    "FINAL_BID|PRICE_PER_LB|COMPANY_NAME|WINNER|BUYER|TOTAL_VALUE|TOTAL_PRICE"
  ))) "auction" else "competition"

  out |>
    dplyr::mutate(
      country = country,
      year = as.integer(year),
      program = program,
      stage = stage,
      process_group = stringr::str_squish(process_group),
      source_url = source_url,
      source_table_id = table_id,
      .before = 1
    )
}

ace_page_document <- function(source_url, user_agent) {
  response <- httr2::request(source_url) |>
    httr2::req_user_agent(user_agent) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()

  page <- response |> httr2::resp_body_html()
  if (length(rvest::html_elements(page, "table")) > 0L) return(page)

  slug <- source_url |>
    stringr::str_remove("/+$") |>
    basename()
  api_url <- stringr::str_replace(
    source_url,
    "/[^/]+/?$",
    "/wp-json/wp/v2/pages"
  )
  api_response <- httr2::request(api_url) |>
    httr2::req_url_query(slug = slug, per_page = 1, `_fields` = "content,link") |>
    httr2::req_user_agent(user_agent) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  if (length(api_response) == 0L || is.null(api_response[[1]]$content$rendered)) {
    stop("No HTML tables found and WordPress page lookup failed: ", source_url)
  }

  xml2::read_html(api_response[[1]]$content$rendered)
}

scrape_ace_event <- function(country, year, source_url, user_agent) {
  page <- ace_page_document(source_url, user_agent)
  nodes <- rvest::html_elements(page, "table")
  if (length(nodes) == 0L) stop("No HTML tables found: ", source_url)

  purrr::map2_dfr(
    nodes,
    seq_along(nodes),
    standardize_ace_table,
    country = country,
    year = year,
    source_url = source_url
  )
}
