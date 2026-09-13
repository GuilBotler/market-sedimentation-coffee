test_that("process vocabulary supports Portuguese and Spanish", {
  expect_equal(canonical_process_family_v2("Despolpado", NA), "Honey / pulped natural")
  expect_equal(canonical_process_family_v2("Lavado", NA), "Washed")
  expect_equal(canonical_process_family_v2("Natural", NA), "Natural")
  expect_equal(canonical_process_family_v2("Anaerobic", NA), "Experimental")
})

test_that("process shares sum to one", {
  x <- tibble::tibble(
    country = c("A", "A"), year = c(2024L, 2024L), program = c("COE", "COE"),
    process_family = c("Natural", "Washed")
  )
  out <- build_process_shares(x)
  expect_equal(sum(out$share_all), 1)
  expect_equal(sum(out$share_reported), 1)
})
