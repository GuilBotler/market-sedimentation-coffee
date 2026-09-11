source(file.path("..", "..", "R", "harmonize.R"))

testthat::test_that("reported process details take precedence over broad headings", {
  result <- canonical_process_family(
    c("Anaerobic fermentation", "Natural", "Honey", "Washed", NA),
    c("Natural", "Traditional Honey & Natural Processes", "Natural", "Washed", "Experimental")
  )

  testthat::expect_equal(
    result,
    c("Experimental", "Natural", "Honey / pulped natural", "Washed", "Experimental")
  )
})

testthat::test_that("ambiguous grouped headings remain explicit", {
  testthat::expect_equal(
    canonical_process_family(NA_character_, "Traditional Honey & Natural Processes"),
    "Natural / honey (grouped)"
  )
  testthat::expect_equal(
    canonical_process_family(NA_character_, NA_character_),
    "Not reported"
  )
})
