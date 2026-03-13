#* 5: Renal Pres by Index Grouping Figure
#+ 5.1: Alluvial Diagram Raw Creation
#- 5.1.1: Run Python script to generate alluvial PNG from raw data
# arch -arm64 forces native Apple Silicon mode — R runs x86_64 (Rosetta), Python venv is arm64
system2(
  "arch",
  args = c(
    "-arm64",
    normalizePath(file.path(getwd(), ".venv/bin/python"), mustWork = FALSE),
    shQuote(normalizePath("Python Scripts/alluvial.py")),
    shQuote(config$paths$raw_data),
    shQuote(normalizePath("Outputs/Figures/Raw"))
  )
)
#- 5.1.2: Import and format edited version from BioRender stored in repo
#! The original alluvial file was created in 5.1.1, exported as PNG, manually edited and formatted in BioRender, and then reimported for the compiled figure below.
{
  p1A <- grid::rasterGrob(
    as.raster(magick::image_read("Outputs/Figures/Raw/p1A_raw.png")),
    interpolate = FALSE
  )
  img_w <- 7.5
  img_h <- img_w * (3493 / 5100)
}
#+ 5.2: Generate Data for Figure Creation
renal_pres_table <- raw_joined |>
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
    `Renal Salvage (%%)` = round(100 * Y / (n()), 1),
    .groups = "drop"
  ) |>
  mutate(
    grade = fct_recode(grade, "III" = "3", "IV" = "4", "V" = "5"),
    index_group = fct_recode(index_group,
      "CM" = "Conservative Management",
      "IR" = "Interventional Radiology",
      "OR" = "Operative Management"
    )
  ) |>
  rename(`AAST Grade` = grade)
#+ 5.3: Create and Assign Figures

# Stacked bar - Renal Salvage, Index Group, Grade
p1B <- plot_renal_pres_stacked(renal_pres_table)
# Line Chart - Renal Salvage % by Grade
p1C <- plot_renal_pres_line(renal_pres_table)
