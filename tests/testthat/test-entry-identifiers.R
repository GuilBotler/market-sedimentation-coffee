source(file.path("..", "..", "R", "harmonize.R"))

test_that("rank normalization identifies split lots without losing the published rank", {
  expect_equal(normalize_rank(c("1A", "1B☘️", "2☘️", "NW☘️")), c("1A", "1B", "2", "NW"))
})

test_that("split ranks map to a common entry rank", {
  clean <- normalize_rank(c("1A", "1B☘️", "2☘️"))
  split <- stringr::str_detect(clean, "^[0-9]+[AB]$")
  entry_rank <- dplyr::if_else(split, stringr::str_remove(clean, "[AB]$"), clean)
  expect_equal(entry_rank, c("1", "1", "2"))
})

test_that("column aliases coalesce row by row across event schemas", {
  data <- tibble::tibble(rank = c("1A", NA), ranking = c(NA, "2"))
  expect_equal(pick_column(data, c("rank", "ranking")), c("1A", "2"))
})

test_that("COE A/B sale lots share the competition match key", {
  expect_equal(
    rank_match_key(c("1", "1A", "1B☘️"), rep("COE", 3)),
    c("1", "1", "1")
  )
})
