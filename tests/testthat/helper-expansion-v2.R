project_root <- normalizePath(file.path("..", ".."), mustWork = TRUE)

base_modules <- file.path(
  project_root,
  c(
    "R/read_source_registry.R",
    "R/scrape_ace_event.R",
    "R/harmonize.R"
  )
)

v2_modules <- list.files(
  file.path(project_root, "R", "expansion_v2"),
  pattern = "\\.[Rr]$",
  full.names = TRUE
)

invisible(lapply(c(base_modules, v2_modules), sys.source, envir = .GlobalEnv))
