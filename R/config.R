project_config <- function() {
  list(
    registry = here::here("data-raw", "source_registry.csv"),
    processed_csv = here::here("data", "processed", "auction_lots.csv"),
    user_agent = paste0(
      "market-sedimentation-coffee/0.1 ",
      "(academic research; https://github.com/GuilBotler/market-sedimentation-coffee)"
    )
  )
}
