#* Figure 1- renal pres by index grouping
renal_pres_table <- demographics_i |>
  select(renal_pres, index_group, grade) |>
  filter(!is.na(renal_pres)) |>
  arrange(renal_pres) |>
  mutate(
    renal_pres = factor(renal_pres, levels = c("N", "Y")),
    grade = factor(grade)
  ) |>
  group_by(index_group, grade) |>
  summarise(
    Y = sum(renal_pres == "Y"),
    N = sum(renal_pres == "N"),
    `% Preserved` = round(100 * Y / (n()), 1),
    .groups = "drop"
  )
write.csv(renal_pres_table, "renal_pres_table.csv", row.names = FALSE)