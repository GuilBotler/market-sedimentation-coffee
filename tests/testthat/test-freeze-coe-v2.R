test_that("frozen lots preserve exclusions and define the matched price sample", {
  lots <- tibble::tibble(
    lot_key = c("lot-1", "lot-2"),
    final_bid_usd_lb = c(10, NA_real_),
    weight_lb = c(100, NA_real_),
    total_value_usd = c(1000, NA_real_),
    buyer = c("Buyer", NA_character_)
  )
  matches <- tibble::tibble(
    lot_key = c("lot-1", "lot-2"),
    entry_key = c("entry-1", NA_character_),
    match_status = c(
      "matched: process group and rank",
      "no competition entry"
    ),
    unmatched_reason = c(
      NA_character_,
      "auction event without competition table"
    )
  )

  result <- build_frozen_auction_lots_v2(lots, matches)

  expect_true(result$eligible_matched_price_sample[[1]])
  expect_false(result$eligible_matched_price_sample[[2]])
  expect_equal(result$value_identity_status[[1]],
               "consistent within 2 percent")
  expect_equal(result$value_identity_status[[2]], "not testable")
})
