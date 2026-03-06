#' Summarize a Binary Outcome by Index Management Strategy and AAST Grade
#'
#' Generates a formatted n/N (%) summary table for a binary (Y/N) outcome
#' variable, cross-tabulated by index management strategy (`index_group`) and
#' stratified by AAST injury grade. Produces one row per management group plus
#' an overall "ALL" row, with columns for each grade subset and all grades
#' combined.
#'
#' @param data A data frame containing at minimum `index_group`, the outcome
#'   column, and the stratification column. Expected to be pre-filtered (e.g.,
#'   early deaths excluded) before passing. Typically `raw_joined` filtered to
#'   `!is.na(index_success)`.
#' @param outcome_col Unquoted name of the binary outcome column to summarize.
#'   Values must be `"Y"` or `"N"`. Examples: `index_success`, `renal_pres`.
#' @param stratify_col Unquoted name of the integer grade column used to split
#'   into grade subgroups. Defaults to `grade`. Subgroups are filtered at
#'   values 3, 4, and 5.
#'
#' @return A tibble with one row per index management group plus an `"ALL"` row.
#'   Columns are `index_group`, `All Grades`, `Grade 3`, `Grade 4`, `Grade 5`.
#'   Each cell contains a string formatted as `"n/N (x%)"`.
#'
#' @examples
#' succ_data <- raw_joined |>
#'   select(grade, index_success, index_group, renal_pres) |>
#'   filter(!is.na(index_success))
#'
#' summarize_index_success(succ_data, index_success)
#' summarize_index_success(succ_data, renal_pres)
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