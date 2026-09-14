test_that("auction aliases are parsed and summary rows are discarded", {
  raw <- tibble::tibble(
    event_id = "event-a",
    event_name = "Example 2025",
    event_type = "COE",
    country = "Example",
    year = 2025L,
    program = "COE",
    process_group = NA_character_,
    rank = c(NA_character_, "Auction Average $/Lb"),
    lot_number = c("1A", NA_character_),
    hight_bid = c("$60.50/lb", "$4.65"),
    weight_kg = c("10", NA_character_),
    high_bidder_s = c("Example buyer", NA_character_),
    source_url = "https://example.com"
  )

  result <- harmonize_auction_v2(raw)

  expect_equal(nrow(result), 1L)
  expect_equal(result$rank_key, "1A")
  expect_equal(result$entry_rank, "1")
  expect_equal(result$final_bid_usd_lb, 60.5)
  expect_equal(result$weight_lb, 10 * 2.2046226218)
  expect_equal(result$buyer, "Example buyer")
})

test_that("auction-only aliases identify auction tables", {
  expect_equal(classify_table_stage_v2(c("lot_no", "hight_bid")), "auction")
  expect_equal(classify_table_stage_v2(c("rank", "bid")), "auction")
})

test_that("numeric lot number replaces an NW label in the rank column", {
  raw <- tibble::tibble(
    event_id = "event-nw",
    event_name = "Example 2025",
    event_type = "COE and NW",
    country = "Example",
    year = 2025L,
    program = "NW",
    process_group = NA_character_,
    rank = "NW",
    lot_number = "30",
    bid = "$7.60/lb",
    source_url = "https://example.com"
  )

  result <- harmonize_auction_v2(raw)

  expect_equal(nrow(result), 1L)
  expect_equal(result$rank_key, "30")
  expect_equal(result$final_bid_usd_lb, 7.6)
})

test_that("decimal ranks are canonicalized and zero ranks are discarded", {
  expect_equal(
    canonical_auction_rank_v2(c("10.00", "5,00", "01a", "0", "Stats")),
    c("10", "5", "1A", NA_character_, NA_character_)
  )
})

test_that("split auction lots map to one competition entry", {
  entries <- tibble::tibble(
    event_id = "event-a", country = "Example", year = 2025L,
    program = "COE", process_group = NA_character_, entry_rank = "1",
    entry_key = "entry-1"
  )
  lots <- tibble::tibble(
    event_id = "event-a", country = "Example", year = 2025L,
    program = "COE", process_group = NA_character_, rank = c("1A", "1B"),
    rank_key = c("1A", "1B"), entry_rank = c("1", "1"),
    lot_key = c("lot-a", "lot-b"), final_bid_usd_lb = c(60, 55),
    weight_lb = c(100, 100), total_value_usd = c(6000, 5500),
    buyer = c("A", "B"), source_url = "https://example.com"
  )

  result <- build_entry_lot_matches_v2(entries, lots)

  expect_equal(nrow(result), 2L)
  expect_true(all(result$entry_key == "entry-1"))
  expect_true(all(result$match_status == "matched: process group and rank"))
  expect_true(all(is.na(result$unmatched_reason)))
})
