## More tests

library(tidyverse)

dir.create(
  "data/audit",
  recursive = TRUE,
  showWarnings = FALSE
)

# 1. Integridade geral
general_audit <- competition |>
  summarise(
    entries = n(),
    countries = n_distinct(country),
    years = n_distinct(year),
    events = n_distinct(paste(country, year)),
    missing_country = sum(is.na(country) | country == ""),
    missing_year = sum(is.na(year)),
    missing_program = sum(
      is.na(program) |
        program == "" |
        program == "Not classified"
    ),
    missing_rank = sum(is.na(rank) | rank == ""),
    missing_score = sum(is.na(score)),
    missing_process = sum(
      process_family == "Not reported"
    )
  )

general_audit

##Process

coverage_audit <- competition |>
  group_by(country, year, program) |>
  summarise(
    entries = n(),
    
    reported_process = sum(
      process_family != "Not reported"
    ),
    
    missing_process = sum(
      process_family == "Not reported"
    ),
    
    coverage_rate = reported_process / entries,
    
    .groups = "drop"
  ) |>
  arrange(coverage_rate, country, year)

print(coverage_audit, n = Inf)


##isolation

coverage_audit |>
  filter(coverage_rate < 1) |>
  print(n = Inf)

coverage_audit |>
  filter(coverage_rate == 0) |>
  print(n = Inf)

## missing content

missing_process_audit <- competition |>
  filter(process_family == "Not reported") |>
  count(
    country,
    year,
    program,
    process_group,
    process,
    sort = TRUE
  )

print(missing_process_audit, n = Inf)


classification_audit <- competition |>
  count(
    process_group,
    process,
    process_family,
    sort = TRUE
  )

View(classification_audit)


classification_audit |>
  filter(
    process_family == "Not reported",
    !is.na(process) | !is.na(process_group)
  ) |>
  print(n = Inf)


suspicious_varieties <- competition |>
  filter(
    !is.na(variety),
    str_detect(
      str_to_lower(variety),
      "natural|washed|h|honey"
    )
  )

#correct

suspicious_varieties <- competition |>
  filter(
    !is.na(variety),
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
  )

View(suspicious_varieties)

duplicate_entries <- competition |>
  count(
    country,
    year,
    program,
    entry_key
  ) |>
  filter(n > 1)

duplicate_entries

deduplication_audit <- tibble(
  raw_competition_rows = nrow(competition_raw),
  unique_entries = nrow(competition),
  removed_rows = nrow(competition_raw) - nrow(competition),
  removal_rate =
    (nrow(competition_raw) - nrow(competition)) /
    nrow(competition_raw)
)

deduplication_audit


missing_events <- anti_join(
  competition_raw |>
    distinct(country, year),
  
  competition |>
    distinct(country, year),
  
  by = c("country", "year")
)

missing_events

invalid_scores <- competition |>
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

invalid_scores



score_audit <- competition |>
  group_by(country, year, program) |>
  summarise(
    entries = n(),
    valid_scores = sum(!is.na(score)),
    missing_scores = sum(is.na(score)),
    
    score_min = if (
      sum(!is.na(score)) > 0
    ) min(score, na.rm = TRUE) else NA_real_,
    
    score_median = if (
      sum(!is.na(score)) > 0
    ) median(score, na.rm = TRUE) else NA_real_,
    
    score_max = if (
      sum(!is.na(score)) > 0
    ) max(score, na.rm = TRUE) else NA_real_,
    
    .groups = "drop"
  )

View(score_audit)

process_shares_audit <- competition |>
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
    )
  ) |>
  
  ungroup()

share_sum_audit <- process_shares_audit |>
  group_by(country, year, program) |>
  summarise(
    share_all_sum = sum(share_all),
    
    share_reported_sum = sum(
      share_reported,
      na.rm = TRUE
    ),
    
    .groups = "drop"
  )

share_sum_audit |>
  filter(
    abs(share_all_sum - 1) > 1e-8 |
      abs(share_reported_sum - 1) > 1e-8
  )

write_csv(
  coverage_audit,
  "data/audit/process_coverage.csv"
)

write_csv(
  classification_audit,
  "data/audit/process_classification.csv"
)

write_csv(
  suspicious_varieties,
  "data/audit/suspicious_varieties.csv"
)

write_csv(
  score_audit,
  "data/audit/score_audit.csv"
)

write_csv(
  process_shares_audit,
  "data/audit/process_shares_audit.csv"
)

write_csv(
  deduplication_audit,
  "data/audit/deduplication_audit.csv"
)


## REsults

general_audit

coverage_audit |>
  filter(coverage_rate < 1) |>
  print(n = Inf)

deduplication_audit

suspicious_varieties

classification_audit |>
  filter(
    process_family == "Not reported",
    !is.na(process) | !is.na(process_group)
  ) |>
  print(n = Inf)

##Correction 02

competition |>
  filter(
    country == "Brazil",
    year == 2023,
    program == "NW"
  ) |>
  select(
    rank,
    farm,
    producer,
    process_group,
    process,
    variety,
    process_family,
    source_url
  ) |>
  View()

competition |>
  filter(
    country == "Brazil",
    year == 2023,
    program == "NW"
  ) |>
  select(
    rank,
    farm,
    producer,
    process_group,
    process,
    variety,
    process_family,
    source_url
  ) |>
  View()

#mex
competition_raw |>
  filter(
    country == "Mexico",
    year == 2023,
    stage == "competition"
  ) |>
  select(
    where(~ any(!is.na(.)))
  ) |> print( n = Inf)
  View()

competition |>
  filter(
    country == "Brazil",
    year == 2022,
    process_family == "Not reported"
  ) |>
  select(
    rank,
    farm,
    process_group,
    process,
    variety,
    source_url
  )

## Solution

canonical_process_family_v2 <- function(
    process,
    process_group
) {
  
  detail <- normalize_key_text(process)
  heading <- normalize_key_text(process_group)
  combined <- paste(detail, heading)
  
  case_when(
    str_detect(
      combined,
      paste0(
        "experimental|anaerob|ferment|",
        "carbonic|maceration|maceracion|",
        "thermal shock|yeast"
      )
    ) ~ "Experimental",
    
    str_detect(
      detail,
      paste0(
        "honey|miel|pulped|depulped|",
        "despolpado|descascado|demucilag|",
        "semi washed|semi lavado"
      )
    ) ~ "Honey / pulped natural",
    
    str_detect(
      detail,
      "natural|dry|seco"
    ) ~ "Natural",
    
    str_detect(
      detail,
      "washed|lavado|wet"
    ) ~ "Washed",
    
    str_detect(
      heading,
      "washed|wet|lavado"
    ) &
      !str_detect(
        heading,
        "natural|honey|dry"
      ) ~ "Washed",
    
    str_detect(
      heading,
      "natural|dry|seco"
    ) &
      !str_detect(
        heading,
        "honey"
      ) ~ "Natural",
    
    str_detect(
      heading,
      "honey"
    ) &
      !str_detect(
        heading,
        "natural"
      ) ~ "Honey / pulped natural",
    
    TRUE ~ "Not reported"
  )
}

harmonize_competition_only <- function(data) {
  
  output <- data |>
    transmute(
      country,
      year,
      program,
      process_group,
      
      rank = as.character(
        pick_column(
          data,
          c("rank", "ranking")
        )
      ),
      
      score = ace_number(
        pick_column(
          data,
          c("score")
        )
      ),
      
      farm = pick_column(
        data,
        c(
          "farm_cws",
          "farm_name",
          "farm"
        )
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
        c(
          "process",
          "processing",
          "proceso"
        )
      ),
      
      variety = pick_column(
        data,
        c(
          "variety",
          "varietal",
          "variedad"
        )
      ),
      
      region = pick_column(
        data,
        c("region")
      ),
      
      source_url
    ) |>
    
    mutate(
      program = replace_na(
        program,
        "Not classified"
      ),
      
      # Correções específicas de duas linhas
      # publicadas com campos aparentemente invertidos.
      swap_process_variety =
        country == "Brazil" &
        year == 2023 &
        program == "NW" &
        farm %in% c(
          "Sítio da Lagoa",
          "Fazenda Samambaia"
        ),
      
      original_process = process,
      original_variety = variety,
      
      process = if_else(
        swap_process_variety,
        original_variety,
        original_process
      ),
      
      variety = if_else(
        swap_process_variety,
        original_process,
        original_variety
      ),
      
      process_family =
        canonical_process_family_v2(
          process,
          process_group
        ),
      
      rank_key = normalize_rank(rank),
      
      # A e B representam a mesma entrada produtiva.
      entry_rank = if_else(
        program == "COE" &
          str_detect(
            rank_key,
            "^[0-9]+[AB]$"
          ),
        str_remove(
          rank_key,
          "[AB]$"
        ),
        rank_key
      ),
      
      farm_key = normalize_key_text(farm),
      
      producer_key =
        normalize_key_text(producer),
      
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
          entry_rank,
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
    ) |>
    
    select(
      -original_process,
      -original_variety
    )
  
  output
}


#Reconstruct base

competition <- harmonize_competition_only(
  competition_raw
)

process_coverage <- competition |>
  group_by(
    country,
    year,
    program
  ) |>
  summarise(
    entries = n(),
    
    reported_process = sum(
      process_family != "Not reported"
    ),
    
    missing_process = sum(
      process_family == "Not reported"
    ),
    
    coverage_rate =
      reported_process / entries,
    
    .groups = "drop"
  )

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
    
    reported_entries = sum(
      entries[
        process_family != "Not reported"
      ]
    ),
    
    share_all =
      entries / total_entries,
    
    share_reported = if_else(
      process_family != "Not reported" &
        reported_entries > 0,
      entries / reported_entries,
      NA_real_
    )
  ) |>
  
  ungroup()

## RTest

competition |>
  summarise(
    entries = n(),
    countries = n_distinct(country),
    events = n_distinct(
      paste(country, year)
    ),
    missing_process = sum(
      process_family == "Not reported"
    )
  )

#mex
competition |>
  filter(
    country == "Mexico",
    year == 2023
  ) |>
  count(
    program,
    process_family
  )
#br
competition |>
  filter(
    country == "Brazil",
    year %in% c(2022, 2023)
  ) |>
  filter(
    process_family == "Not reported"
  )

#A/B

competition |>
  filter(
    program == "COE",
    str_detect(rank_key, "^[0-9]+[AB]$")
  ) |>
  count(
    country,
    year,
    program,
    entry_key
  ) |>
  filter(n > 1)
