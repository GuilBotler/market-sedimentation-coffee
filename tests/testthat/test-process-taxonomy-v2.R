testthat::test_that("composite treatments are experimental and retain their base", {
  process <- c(
    "Natural Anaerobic", "Washed Anaerobic", "Honey double fermentation",
    "Lactic Natural", "Mossto Natural", "Carbonic Maceration Honey",
    "Anaerobic NP"
  )

  testthat::expect_equal(
    innovation_class_v2(process),
    rep("Experimental", length(process))
  )
  testthat::expect_equal(
    canonical_base_process_v2(process),
    c(
      "Natural", "Washed", "Honey / pulped natural", "Natural",
      "Natural", "Honey / pulped natural", "Natural"
    )
  )
  testthat::expect_equal(
    experimental_method_v2(process),
    c(
      "Anaerobic", "Anaerobic", "Double fermentation",
      "Lactic fermentation", "Mosto fermentation",
      "Carbonic maceration", "Anaerobic"
    )
  )
})

testthat::test_that("traditional multiword processes remain conventional", {
  process <- c(
    "Pulped Natural", "Fully Washed", "Dry/Natural", "Wet Hulled",
    "Semi-Washed", "SEMIL - WASHED", "Black Honey"
  )

  testthat::expect_equal(
    innovation_class_v2(process),
    rep("Conventional", length(process))
  )
  testthat::expect_equal(
    canonical_base_process_v2(process),
    c(
      "Honey / pulped natural", "Washed", "Natural", "Wet hulled",
      "Honey / pulped natural", "Honey / pulped natural",
      "Honey / pulped natural"
    )
  )
})

testthat::test_that("experimental headings classify plain base labels", {
  process <- c("Washed", "Natural", "Honey")
  heading <- rep("Experimental", 3L)

  testthat::expect_equal(
    innovation_class_v2(process, heading),
    rep("Experimental", 3L)
  )
  testthat::expect_equal(
    experimental_method_v2(process, heading),
    rep("Experimental unspecified", 3L)
  )
  testthat::expect_equal(
    canonical_base_process_v2(process, heading),
    c("Washed", "Natural", "Honey / pulped natural")
  )
})

testthat::test_that("administrative labels are not processes", {
  process <- c("Pending", NA_character_)

  testthat::expect_equal(
    process_label_status_v2(process),
    c("invalid process label", "not reported")
  )
  testthat::expect_equal(
    canonical_process_family_v2(process, NA_character_),
    rep("Not reported", 2L)
  )
})

testthat::test_that("proprietary labels inherit an explicit experimental heading", {
  testthat::expect_equal(
    process_label_status_v2("Pedro Bras Top"),
    "reported"
  )
  testthat::expect_equal(
    innovation_class_v2("Pedro Bras Top", "Experimental"),
    "Experimental"
  )
  testthat::expect_equal(
    experimental_method_v2("Pedro Bras Top", "Experimental"),
    "Experimental unspecified"
  )
})

testthat::test_that("2018 technologies are left-censored", {
  entries <- tibble::tibble(
    event_id = paste0("e", 1:5),
    program = "COE",
    entry_key = paste0("entry", 1:5),
    country = "Brazil",
    year = c(2018L, 2019L, 2021L, 2021L, 2022L),
    entry_rank = as.character(1:5),
    process_classification_source = "reported process",
    process_label_status = "reported",
    base_process = c("Natural", "Natural", "Washed", "Washed", "Washed"),
    innovation_class = c(
      "Experimental", "Experimental", "Experimental", "Experimental",
      "Conventional"
    ),
    experimental_method = c(
      "Anaerobic", "Anaerobic", "Carbonic maceration",
      "Carbonic maceration", NA_character_
    )
  )

  result <- build_innovation_entries_v2(entries)
  anaerobic <- result |>
    dplyr::filter(experimental_method == "Anaerobic")
  carbonic <- result |>
    dplyr::filter(experimental_method == "Carbonic maceration")

  testthat::expect_true(all(anaerobic$left_censored_at_baseline))
  testthat::expect_false(any(anaerobic$first_observed_experimental_entry))
  testthat::expect_true(all(carbonic$appearance_after_baseline))
  testthat::expect_true(all(carbonic$first_observed_experimental_entry))
})

testthat::test_that("split auction lots are also summarized by entry", {
  lots <- tibble::tibble(
    event_id = "event-1",
    program = "COE",
    entry_key = "entry-1",
    country = "Brazil",
    year = 2024L,
    entry_rank = "1",
    farm = "Example farm",
    score = 90,
    process = "Natural Anaerobic",
    base_process = "Natural",
    innovation_class = "Experimental",
    experimental_method = "Anaerobic",
    experimental_technology = "Natural | Anaerobic",
    final_bid_usd_lb = c(10, 20),
    weight_reported = TRUE,
    weight_lb = c(100, 200)
  )

  result <- build_innovation_remuneration_entries_v2(lots)

  testthat::expect_equal(nrow(result), 1L)
  testthat::expect_equal(result$auction_lots, 2L)
  testthat::expect_equal(result$mean_price_usd_lb, 15)
  testthat::expect_equal(result$weighted_mean_price_usd_lb, 50 / 3)
})
