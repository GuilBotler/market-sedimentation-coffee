## expandir a base de dados

library(tidyverse)
library(rvest)
library(xml2)

archive_url <- paste0(
  "https://allianceforcoffeeexcellence.org/",
  "competition-auction-results/"
)

archive_page <- read_html(archive_url)

archive_url <- paste0(
  "https://allianceforcoffeeexcellence.org/",
  "competition-auction-results/"
)

archive_page <- read_html(archive_url)

link_nodes <- archive_page |>
  html_elements("a")

library(tidyverse)
library(rvest)
library(xml2)

archive_url <- paste0(
  "https://allianceforcoffeeexcellence.org/",
  "competition-auction-results/"
)

archive_page <- read_html(archive_url)

link_nodes <- html_elements(
  archive_page,
  "a"
)

archive_links <- tibble(
  link_text = html_text2(link_nodes),
  href = html_attr(link_nodes, "href")
) |>
  filter(!is.na(href)) |>
  mutate(
    source_url = xml2::url_absolute(
      href,
      archive_url
    ),
    
    slug = source_url |>
      str_remove("/$") |>
      basename() |>
      str_to_lower(),
    
    year_text = str_extract(
      paste(link_text, slug),
      "(19|20)[0-9]{2}"
    ),
    
    year = as.integer(year_text)
  ) |>
  filter(
    !is.na(year),
    year >= 1999,
    year <= 2019,
    str_detect(
      source_url,
      "allianceforcoffeeexcellence.org"
    )
  ) |>
  distinct(
    source_url,
    .keep_all = TRUE
  )


exists("archive_links")

nrow(archive_links)

archive_links |>
  count(year) |>
  arrange(year) |>
  print(n = Inf)


#Countries

country_dictionary <- tribble(
  ~country,       ~slug_key,
  "Bolivia",      "bolivia",
  "Brazil",       "brazil",
  "Burundi",      "burundi",
  "Colombia",     "colombia",
  "Costa Rica",   "costa-rica",
  "Ecuador",      "ecuador",
  "El Salvador",  "el-salvador",
  "Ethiopia",     "ethiopia",
  "Guatemala",    "guatemala",
  "Honduras",     "honduras",
  "Indonesia",    "indonesia",
  "Mexico",       "mexico",
  "Nicaragua",    "nicaragua",
  "Panama",       "panama",
  "Peru",         "peru",
  "Rwanda",       "rwanda",
  "Thailand",     "thailand",
  "Taiwan",       "taiwan"
)

identify_country <- function(slug) {
  
  matches <- country_dictionary |>
    filter(
      str_detect(
        slug,
        paste0("^", slug_key, "(-|$)")
      )
    )
  
  if (nrow(matches) == 0) {
    return(NA_character_)
  }
  
  matches$country[[1]]
}

#table

historical_candidates <- archive_links |>
  mutate(
    country = map_chr(
      slug,
      identify_country
    ),
    
    event_name = if_else(
      is.na(link_text) | link_text == "",
      slug,
      link_text
    ),
    
    event_type = case_when(
      str_detect(
        slug,
        "pulped-natural"
      ) ~ "COE Pulped Natural",
      
      str_detect(
        slug,
        "natural"
      ) ~ "COE Natural",
      
      str_detect(
        slug,
        "north|south"
      ) ~ "COE regional",
      
      TRUE ~ "COE"
    ),
    
    accessed_at = as.character(
      Sys.Date()
    ),
    
    active = TRUE,
    
    notes = paste(
      "Official ACE historical",
      "results page"
    )
  ) |>
  
  select(
    country,
    year,
    event_name,
    event_type,
    source_url,
    accessed_at,
    active,
    notes
  ) |>
  
  arrange(
    country,
    year,
    source_url
  )

#check

historical_candidates |>
  summarise(
    pages = n(),
    identified = sum(!is.na(country)),
    unidentified = sum(is.na(country)),
    countries = n_distinct(
      country,
      na.rm = TRUE
    ),
    first_year = min(year),
    last_year = max(year)
  )

historical_candidates |>
  filter(is.na(country)) |>
  select(
    year,
    event_name,
    source_url
  ) |>
  print(n = Inf)

historical_candidates |>
  count(
    country,
    year,
    name = "pages"
  ) |>
  arrange(
    country,
    year
  ) |>
  print(n = Inf)

historical_candidates |>
  count(
    country,
    year,
    name = "pages"
  ) |>
  filter(pages > 1) |>
  arrange(
    country,
    year
  ) |>
  print(n = Inf)

#save

dir.create(
  "data/audit",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  historical_candidates,
  paste0(
    "data/audit/",
    "historical_candidates_1999_2019.csv"
  )
)


historical_registry <- historical_candidates |>
  filter(!is.na(country))


registry_fixed <- registry |>
  mutate(
    year = as.integer(year),
    accessed_at = as.Date(accessed_at),
    active = as.logical(active)
  )

historical_registry_fixed <- historical_registry |>
  mutate(
    year = as.integer(year),
    accessed_at = as.Date(accessed_at),
    active = as.logical(active)
  )

registry_expanded <- bind_rows(
  registry_fixed,
  historical_registry_fixed
) |>
  distinct(
    source_url,
    .keep_all = TRUE
  ) |>
  arrange(
    country,
    year,
    source_url
  )

## check

registry_expanded |>
  summarise(
    pages = n(),
    countries = n_distinct(country),
    first_year = min(year, na.rm = TRUE),
    last_year = max(year, na.rm = TRUE)
  )

registry_expanded |>
  count(country) |>
  arrange(desc(n)) |>
  print(n = Inf)

#save
write_csv(
  registry_expanded,
  "data-raw/source_registry_expanded.csv"
)

file.exists(
  "data-raw/source_registry_expanded.csv"
)
