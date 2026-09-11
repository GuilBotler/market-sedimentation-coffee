source(file.path("..", "..", "R", "commodity_prices.R"))

testthat::test_that("FRED wine series keeps its own index unit", {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)
  writeLines(
    c(
      "observation_date,PCU3121303121300",
      "1998-12-01,100.000",
      "1999-01-01,100.100",
      "1999-02-01,."
    ),
    path
  )

  result <- fred_wine_price_index(path, start_year = 1999L)

  testthat::expect_equal(nrow(result), 1L)
  testthat::expect_equal(result$value, 100.1)
  testthat::expect_equal(result$unit, "Index (Dec 1998=100)")
  testthat::expect_equal(result$market_scope, "United States producer price index")
})
