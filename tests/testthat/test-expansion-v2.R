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
