test_that("historical event title is used only when explicit", {
  expect_equal(event_declared_process_family("COE Natural", "Brazil 2015"), "Natural")
  expect_equal(event_declared_process_family("COE Pulped Natural", "Brazil 2015"),
               "Honey / pulped natural")
  expect_true(is.na(event_declared_process_family("COE", "Colombia 2010")))
})

test_that("auction tables do not require score", {
  expect_equal(classify_table_stage_v2(c("rank", "price_per_lb", "buyer")), "auction")
  expect_equal(classify_table_stage_v2(c("rank", "score", "farm")), "competition")
})

test_that("event identity prevents cross-event collisions", {
  keys <- paste(c("event-a", "event-b"), "COE", NA, "1", sep = "|")
  expect_equal(length(unique(keys)), 2L)
})

test_that("V2 audit reports raw-to-entry reduction by event", {
  raw <- tibble::tibble(
    event_id = c("a", "a"), country = "Brazil", year = 2024L,
    event_name = "Brazil 2024", event_type = "COE", source_url = "example",
    download_status = "success", download_error = NA_character_,
    stage = "competition"
  )
  competition <- tibble::tibble(
    event_id = "a", country = "Brazil", year = 2024L,
    event_name = "Brazil 2024", program = "COE", entry_key = "a|COE|1",
    score = 90, variety = "Geisha", process_family = "Natural"
  )
  auction <- tibble::tibble(
    event_id = character(), program = character(), lot_key = character()
  )
  shares <- tibble::tibble(
    event_id = "a", country = "Brazil", year = 2024L, program = "COE",
    share_all = 1, share_reported = 1, coverage_rate = 1
  )
  audit <- build_v2_audit(raw, competition, auction, tibble::tibble(), shares)
  expect_equal(audit$entry_reduction$removed, 1L)
  expect_equal(audit$entry_reduction$retention_rate, 0.5)
})

test_that("sparse duplicate summaries are detected from coffee overlap", {
  detailed <- tibble::tibble(
    event_id = "a", source_table_id = 1L, stage = "competition",
    farm = paste("Farm", 1:6), score = 90 + 1:6 / 10,
    process = "Natural", variety = "Geisha"
  )
  summary <- detailed |>
    dplyr::mutate(
      source_table_id = 5L,
      process = NA_character_, variety = NA_character_
    )
  detected <- identify_sparse_summary_tables_v2(
    dplyr::bind_rows(detailed, summary)
  )
  expect_equal(detected$source_table_id, 5L)
  expect_equal(detected$overlap_rate, 1)
})
