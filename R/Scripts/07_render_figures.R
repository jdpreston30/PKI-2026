#* 7: Render Figures
#+ 7.1: Ensure output directory exists
if (!dir.exists("Outputs/Figures/Final")) dir.create("Outputs/Figures/Final", recursive = TRUE)
#+ 7.2: Figure 1 — Renal Salvage (1A alluvial + 1B stacked bar + 1C line chart)
# Reference proportions: "Figure 1" y=10.43, panel letters y=10.047,
# plot top edge ~10.15 (letters just below), plots height ~2.75
fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  # 1A: Alluvial diagram (full-width, top)
  draw_grob(p1A, x = 1.0274, y = 3.6700, width = 6.4453, height = 7.7074) +
  # 1B: Stacked bar (left, bottom)
  draw_plot(p1B, x = 0.6667, y = 2.2667, width = 3.6, height = 2.75) +
  # 1C: Line chart (right, bottom)
  draw_plot(p1C, x = 4.175, y = 2.2667, width = 3.6, height = 2.78) +
  figure_labels(list(
    A          = c(0.645,     10.0173),
    B          = c(0.645,     4.9137),
    C          = c(4.1533,    4.9137),
    "Figure 1" = c(0.49,      10.43)
  )) +
  # Alluvial node and column header annotations (pixel coords, top-left origin)
  alluvial_annotations(list(
    # Column 1
    list(text = "Injury\nGrade",          x_px = 868,   y_px = 641,    type = "column"),
    list(text = "Grade\nIII\n(n=51)",     x_px = 868,   y_px = 1211, type = "box"),
    list(text = "Grade\nIV\n(n=54)",     x_px = 868,   y_px = 2115,  type = "box"),
    list(text = "Grade\nV\n(n=46)",      x_px = 868,   y_px = 2980, type = "box"),
    # Column 2
    list(text = "Index\nManagement", x_px = 2550,  y_px = 641,    type = "column"),
    list(text = "CM\n(n=41)",        x_px = 2550,    y_px = 1138, type = "box"),
    list(text = "IR\n(n=16)",        x_px = 2550,    y_px = 1683,   type = "box"),
    list(text = "OR\n(n=94)",        x_px = 2550,    y_px = 2624, type = "box"),
    # Column 3
    list(text = "Secondary\nManagement", x_px = 4232, y_px = 641, type = "column"),
    list(text = "IR\n(n=14)", x_px = 4232, y_px = 1851, type = "box"),
    list(text = "OR\n(n=9)", x_px = 4232, y_px = 2250, type = "box", lineheight = 0.8),
    list(text = "Died\n(n=13)", x_px = 4232, y_px = 2624, type = "box")
  ))
#+ 7.3: Print PNG
print_to_png(fig1, "fig1.png", output_dir = "Outputs/Figures/Final")
