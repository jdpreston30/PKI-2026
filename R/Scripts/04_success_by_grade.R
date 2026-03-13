#* 4: Success of Index Management
#+ 4.1: Prep data
succ_salvage_final <- raw_joined |>
  select(grade, index_success, index_group, renal_pres) |>
  filter(!is.na(index_success))
#+ 4.2: Create Sub-Tables
#- 4.2.1: Index success table
index_success_table <- summarize_index_success(succ_salvage_final, index_success) |>
  mutate(variable = "Index Success")
#- 4.2.2: Renal salvage table
renal_salvage_table <- summarize_index_success(succ_salvage_final, renal_pres) |>
  mutate(variable = "Renal Salvage")
#- 4.2.3: Combine and insert section header rows for word_export formatting
salvage_succ_table <- bind_rows(
  tibble(Variable = "Index Management Success", `Grade III` = "", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  index_success_table |> rename(Variable = index_group) |> select(-variable) |>
    mutate(Variable = if_else(Variable == "ALL", "All Management Strategies", Variable)),
  tibble(Variable = "Renal Salvage", `Grade III` = "", `Grade IV` = "", `Grade V` = "", `All Grades` = ""),
  renal_salvage_table |> rename(Variable = index_group) |> select(-variable) |>
    mutate(Variable = if_else(Variable == "ALL", "All Management Strategies", Variable))
)
#+ 4.3: Export table
T4 <- ternStyle(
  tbl = salvage_succ_table,
  table_caption = "Table 4. Index management success and renal salvage stratified by index management strategy and injury grade.",
  subheader_rows = c("Index Management Success", "Renal Salvage"),
  manual_italic_indent = c(
    "Conservative Management", "Interventional Radiology",
    "Operative Management", "All Management Strategies"
  ),
  bold_rows    = c(5, 10),
  italic_rows  = c(5, 10),
  bold_cols    = 5,
  italic_cols  = 5,
  header_format_follow = TRUE,
  col1_header  = "Variable\n   Index Management Strategy",
  font_size = 9
)
