## Armonizar - depois do collect data
harmonize_competition_only <- function(data) {
  
  data |>
    transmute(
      country,
      year,
      program,
      process_group,
      
      rank = as.character(
        pick_column(data, c("rank", "ranking"))
      ),
      
      score = ace_number(
        pick_column(data, c("score"))
      ),
      
      farm = pick_column(
        data,
        c("farm_cws", "farm_name", "farm")
      ),
      
      producer = pick_column(
        data,
        c(
          "farmer_representative",
          "farmer",
          "producer"
        )
      ),
      
      process = pick_column(
        data,
        c("process", "processing")
      ),
      
      variety = pick_column(
        data,
        c("variety", "varietal")
      ),
      
      region = pick_column(
        data,
        c("region")
      ),
      
      source_url
    ) |>
    
    mutate(
      program = replace_na(program, "Not classified"),
      
      process_family = canonical_process_family(
        process,
        process_group
      ),
      
      rank_key = normalize_rank(rank),
      farm_key = normalize_key_text(farm),
      producer_key = normalize_key_text(producer),
      
      entry_key = case_when(
        program == "NW" ~ paste(
          country,
          year,
          program,
          farm_key,
          producer_key,
          sprintf("%.2f", score),
          sep = "|"
        ),
        
        TRUE ~ paste(
          country,
          year,
          program,
          process_group,
          rank_key,
          sep = "|"
        )
      )
    ) |>
    
    distinct(
      country,
      year,
      program,
      entry_key,
      .keep_all = TRUE
    )
}

##Build the DAtaBAse

competition <- harmonize_competition_only(
  competition_raw
)


## Check

competition |>
  summarise(
    entries = n(),
    origins = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(paste(country, year))
  )

## VErify Process Classification

competition |>
  count(
    process_group,
    process,
    process_family,
    sort = TRUE
  ) |>
  View()

## VErify cover

process_coverage <- competition |>
  group_by(country, year, program) |>
  summarise(
    entries = n(),
    process_reported = sum(
      process_family != "Not reported"
    ),
    process_missing = sum(
      process_family == "Not reported"
    ),
    coverage_rate = process_reported / entries,
    .groups = "drop"
  )

View(process_coverage)

## Contruir Participacao por processo

process_shares <- competition |>
  count(
    country,
    year,
    program,
    process_family,
    name = "entries"
  ) |>
  
  group_by(
    country,
    year,
    program
  ) |>
  
  mutate(
    total_entries = sum(entries),
    share = entries / total_entries
  ) |>
  
  ungroup() |>
  
  arrange(
    country,
    year,
    program,
    process_family
  )

## SAlva

readr::write_csv(
  competition,
  "data/processed/competition_entries.csv"
)

readr::write_csv(
  process_coverage,
  "data/processed/process_coverage.csv"
)

readr::write_csv(
  process_shares,
  "data/processed/process_shares_country_year.csv"
)

##VEr Evolucao

library(ggplot2)

process_shares |>
  filter(
    program == "COE",
    process_family != "Not reported"
  ) |>
  
  ggplot(
    aes(
      x = year,
      y = share,
      color = process_family,
      group = process_family
    )
  ) +
  
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.8) +
  
  facet_wrap(
    vars(country),
    scales = "free_x"
  ) +
  
  scale_y_continuous(
    labels = scales::percent
  ) +
  
  labs(
    title = "Evolução dos processos nas entradas do COE",
    x = NULL,
    y = "Participação nas entradas",
    color = "Processo"
  ) +
  
  theme_minimal()

### TEstes

##Resumo GEral

competition |>
  summarise(
    entries = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(paste(country, year)),
    missing_country = sum(is.na(country)),
    missing_year = sum(is.na(year)),
    missing_program = sum(
      is.na(program) |
        program == "Not classified"
    ),
    missing_process = sum(
      process_family == "Not reported"
    )
  )
#result ok

## Cover by event

process_coverage |>
  arrange(coverage_rate) |>
  print(n = Inf)

process_coverage |>
  filter(coverage_rate == 0)

process_coverage |>
  filter(
    coverage_rate > 0,
    coverage_rate < 1
  )

competition |>
  filter(process_family == "Not reported") |>
  count(
    country,
    year,
    program,
    process_group,
    process,
    sort = TRUE
  ) |>
  print(n = Inf)

##Location

competition |>
  filter(
    str_detect(
      str_to_lower(variety),
      "natural|washed|honey|anaerob|ferment"
    )
  ) |>
  select(
    country,
    year,
    program,
    rank,
    farm,
    process,
    variety,
    process_family,
    source_url
  ) |>
  View()

## missed

raw_events <- competition_raw |>
  distinct(country, year)

clean_events <- competition |>
  distinct(country, year)

anti_join(
  raw_events,
  clean_events,
  by = c("country", "year")
)
#result ok

##duplicated

competition |>
  count(
    country,
    year,
    program,
    entry_key
  ) |>
  filter(n > 1)

tibble(
  raw_rows = nrow(competition_raw),
  unique_entries = nrow(competition),
  removed_rows = nrow(competition_raw) - nrow(competition)
)

##Scores

competition |>
  filter(
    !is.na(score),
    score < 0 | score > 100
    
  ) |>
  select(
    country,
    year,
    program,
    rank,
    score,
    source_url
  )

## Distribution

competition |>
  group_by(country, year, program) |>
  summarise(
    n = n(),
    score_missing = sum(is.na(score)),
    score_min = min(score, na.rm = TRUE),
    score_median = median(score, na.rm = TRUE),
    score_max = max(score, na.rm = TRUE),
    .groups = "drop"
  ) |>
  View()

# 100 participation

process_shares |>
  group_by(country, year, program) |>
  summarise(
    share_sum = sum(share),
    .groups = "drop"
  ) |>
  filter(abs(share_sum - 1) > 1e-8)

#Paarticiption

process_shares_checked <- competition |>
  count(
    country,
    year,
    program,
    process_family,
    name = "entries"
  ) |>
  
  group_by(country, year, program) |>
  
  mutate(
    total_entries = sum(entries),
    
    reported_entries = sum(
      entries[process_family != "Not reported"]
    ),
    
    share_all = entries / total_entries,
    
    share_reported = if_else(
      process_family != "Not reported" &
        reported_entries > 0,
      entries / reported_entries,
      NA_real_
    ),
    
    coverage_rate = reported_entries / total_entries
  ) |>
  
  ungroup()

## Participation verification

process_shares |>
  group_by(country, year, program) |>
  summarise(
    soma = sum(share),
    .groups = "drop"
  ) |>
  filter(abs(soma - 1) > 1e-8)

process_shares |>
  filter(process_family == "Not reported") |>
  arrange(country, year) |>
  print(n = Inf)

process_coverage |>
  arrange(coverage_rate) |>
  print(n = Inf)


scale_x_continuous(
  breaks = 2021:2025
)

ggsave(
  "PArticipacao_processo_ampliada.pdf",
  width = 14,
  height = 10
)
