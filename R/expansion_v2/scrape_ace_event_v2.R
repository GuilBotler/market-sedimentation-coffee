classify_program_v2 <- function(section_heading, default_program = "COE") {
  out <- dplyr::case_when(
    stringr::str_detect(section_heading, stringr::regex("National|NW", ignore_case = TRUE)) ~ "NW",
    stringr::str_detect(section_heading, stringr::regex("COE|Cup of Excellence", ignore_case = TRUE)) ~ "COE",
    TRUE ~ NA_character_
  )
  dplyr::coalesce(out, default_program)
}

promote_first_row_to_header <- function(table_node) {
  raw <- rvest::html_table(table_node, header = FALSE, fill = TRUE, trim = TRUE)
  if (nrow(raw) < 2L) return(tibble::tibble())
  headers <- janitor::make_clean_names(as.character(unlist(raw[1, ], use.names = FALSE)))
  out <- raw[-1, , drop = FALSE]
  names(out) <- make.unique(headers)
  dplyr::mutate(out, dplyr::across(dplyr::everything(), as.character))
}

classify_table_stage_v2 <- function(column_names) {
  nms <- tolower(column_names)
  auction_markers <- paste(
    "final_bid", "price_per_lb", "price_lb", "high_bid", "winning_bid",
    "company_name", "buyer", "winner", "total_value", "total_price", sep = "|"
  )
  has_auction <- any(stringr::str_detect(nms, auction_markers))
  has_rank <- any(nms %in% c("rank", "ranking", "lot", "lot_number", "position"))
  has_score <- any(stringr::str_detect(nms, "^score$|cupping_score|final_score"))
  if (has_auction) return("auction")
  if (has_rank && has_score) return("competition")
  NA_character_
}

standardize_ace_table_v2 <- function(table_node, table_id, event_meta) {
  out <- promote_first_row_to_header(table_node)
  if (nrow(out) == 0L) return(tibble::tibble())
  stage <- classify_table_stage_v2(names(out))
  if (is.na(stage)) return(tibble::tibble())

  section <- nearest_heading(table_node, "h4")
  process_group <- nearest_heading(table_node, "h2")
  default_program <- ifelse(stringr::str_detect(event_meta$event_type, "NW"), "NW", "COE")
  program <- classify_program_v2(section, default_program)

  if (!any(names(out) %in% c("rank", "ranking", "lot", "lot_number", "position"))) {
    if (identical(program, "NW")) out$rank <- "NW" else return(tibble::tibble())
  }

  out |>
    dplyr::mutate(
      event_id = digest::digest(event_meta$source_url, algo = "xxhash64"),
      country = event_meta$country,
      year = as.integer(event_meta$year),
      event_name = event_meta$event_name,
      event_type = event_meta$event_type,
      program = program,
      stage = stage,
      process_group = stringr::str_squish(process_group),
      source_url = event_meta$source_url,
      source_table_id = table_id,
      .before = 1
    )
}

scrape_ace_event_v2 <- function(country, year, event_name, event_type, source_url, user_agent) {
  page <- ace_page_document(source_url, user_agent)
  nodes <- rvest::html_elements(page, "table")
  if (length(nodes) == 0L) stop("No HTML tables found: ", source_url)
  event_meta <- list(country = country, year = year, event_name = event_name,
                     event_type = event_type, source_url = source_url)
  purrr::map2_dfr(nodes, seq_along(nodes), standardize_ace_table_v2,
                  event_meta = event_meta)
}
