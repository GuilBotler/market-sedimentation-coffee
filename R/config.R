project_config <- function() {
  list(
    registry = here::here("data-raw", "source_registry.csv"),
    processed_csv = here::here("data", "processed", "auction_lots.csv"),
    source_audit_csv = here::here("data", "processed", "source_audit.csv"),
    commodity_csv = here::here("data", "processed", "commodity_prices.csv"),
    world_bank_monthly_url = paste0(
      "https://thedocs.worldbank.org/en/doc/",
      "74e8be41ceb20fa0da750cda2f6b9e4e-0050012026/related/",
      "CMO-Historical-Data-Monthly.xlsx"
    ),
    fred_wine_url = paste0(
      "https://fred.stlouisfed.org/graph/fredgraph.csv?",
      "id=PCU3121303121300"
    ),
    user_agent = paste0(
      "market-sedimentation-coffee/0.1 ",
      "(academic research; https://github.com/GuilBotler/market-sedimentation-coffee)"
    )
  )
}
