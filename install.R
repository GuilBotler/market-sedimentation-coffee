packages <- c(
  "targets", "tarchetypes", "tidyverse", "rvest", "xml2", "janitor",
  "httr2", "lubridate", "stringi", "countrycode", "fixest", "broom",
  "modelsummary", "plotly", "DT", "scales", "here", "digest", "testthat"
)

missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing) > 0L) install.packages(missing)

