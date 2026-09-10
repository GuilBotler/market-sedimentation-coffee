source("R/scrape_ace_event.R")

test_that("ACE numeric strings parse across locale formats", {
  expect_equal(ace_number("$60,10"), 60.10)
  expect_equal(ace_number("$15.902,46"), 15902.46)
  expect_equal(ace_number("$15,902.46"), 15902.46)
  expect_equal(ace_number("396,80"), 396.80)
  expect_true(is.na(ace_number("")))
})
