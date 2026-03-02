#* Tables 4
#+ Helper function to generate n/N (%) summary
summarize_index_success <- function(data, outcome_col, stratify_col = grade) {
  outcome_col <- rlang::ensym(outcome_col)
  stratify_col <- rlang::ensym(stratify_col)

  # Internal helper for n/N (%) summary
  get_success_summary <- function(df) {
    df |>
      group_by(index_group) |>
      summarise(
        N_Y = sum(!!outcome_col == "Y"),
        N_N = sum(!!outcome_col == "N"),
        Total = N_Y + N_N,
        Percent_Y = round(100 * N_Y / Total, 1),
        Summary = paste0(N_Y, "/", Total, " (", Percent_Y, "%)"),
        .groups = "drop"
      ) |>
      select(index_group, Summary)
  }

  # Get stratified summaries
  tbl_all <- get_success_summary(data) |> rename(`All Grades` = Summary)
  tbl_g3 <- get_success_summary(data |> filter(!!stratify_col == 3)) |> rename(`Grade 3` = Summary)
  tbl_g4 <- get_success_summary(data |> filter(!!stratify_col == 4)) |> rename(`Grade 4` = Summary)
  tbl_g5 <- get_success_summary(data |> filter(!!stratify_col == 5)) |> rename(`Grade 5` = Summary)

  # Join tables
  summary_tbl <- tbl_all |>
    full_join(tbl_g3, by = "index_group") |>
    full_join(tbl_g4, by = "index_group") |>
    full_join(tbl_g5, by = "index_group") |>
    arrange(index_group)

  # Compute overall (ALL) row
  total_all <- data |>
    summarise(
      N_Y = sum(!!outcome_col == "Y"),
      N_N = sum(!!outcome_col == "N"),
      Total = N_Y + N_N,
      `All Grades` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
    )

  total_g3 <- data |>
    filter(!!stratify_col == 3) |>
    summarise(
      N_Y = sum(!!outcome_col == "Y"),
      N_N = sum(!!outcome_col == "N"),
      Total = N_Y + N_N,
      `Grade 3` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
    ) |>
    select(`Grade 3`)

  total_g4 <- data |>
    filter(!!stratify_col == 4) |>
    summarise(
      N_Y = sum(!!outcome_col == "Y"),
      N_N = sum(!!outcome_col == "N"),
      Total = N_Y + N_N,
      `Grade 4` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
    ) |>
    select(`Grade 4`)

  total_g5 <- data |>
    filter(!!stratify_col == 5) |>
    summarise(
      N_Y = sum(!!outcome_col == "Y"),
      N_N = sum(!!outcome_col == "N"),
      Total = N_Y + N_N,
      `Grade 5` = paste0(N_Y, "/", Total, " (", round(100 * N_Y / Total, 1), "%)")
    ) |>
    select(`Grade 5`)

  # Bind overall row
  total_row <- bind_cols(
    tibble(index_group = "ALL"),
    total_all |> select(`All Grades`),
    total_g3,
    total_g4,
    total_g5
  )

  bind_rows(summary_tbl, total_row)
}
#+ Prep data
succ_salvage_final <- demographics_i |>
  select(grade, index_success, index_group, renal_pres) |>
  filter(!is.na(index_success))
#+ Index success table
index_success_table <- summarize_index_success(succ_salvage_final, index_success) |>
  mutate(variable = "Index Success")
#+ Renal salvage table
renal_salvage_table <- summarize_index_success(succ_salvage_final, renal_pres) |>
  mutate(variable = "Renal Salvage")
salvage_succ_table <- rbind(index_success_table, renal_salvage_table)
write.csv(salvage_succ_table, "salvage_succ_table.csv", row.names = FALSE)
