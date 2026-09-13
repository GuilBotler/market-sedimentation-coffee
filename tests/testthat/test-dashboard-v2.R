test_that("dashboard V2 inputs preserve their analytical units", {
  competition <- readr::read_csv(
    "data/processed/v2/competition_entries.csv", show_col_types = FALSE
  )
  auctions <- readr::read_csv(
    "data/processed/v2/auction_lots.csv", show_col_types = FALSE
  )

  expect_true(all(c(
    "event_id", "entry_key", "process_family",
    "process_classification_source"
  ) %in% names(competition)))
  expect_true(all(c(
    "event_id", "lot_key", "final_bid_usd_lb", "buyer"
  ) %in% names(auctions)))

  expect_equal(nrow(competition), dplyr::n_distinct(competition$entry_key))
  expect_equal(nrow(auctions), dplyr::n_distinct(auctions$lot_key))
  expect_setequal(
    unique(competition$process_classification_source),
    c("reported process", "ACE event title", "not reported")
  )
  expect_true(min(auctions$year, na.rm = TRUE) <= 1999L)
  expect_true(max(auctions$year, na.rm = TRUE) >= 2025L)
})
