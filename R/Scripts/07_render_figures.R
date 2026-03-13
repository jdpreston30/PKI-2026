#* 7: Render Figures
#+ 7.1: Ensure output directory exists
if (!dir.exists("Outputs/Figures/Final/PNG")) dir.create("Outputs/Figures/Final/PNG", recursive = TRUE)
#+ 7.2: Figure 1 — Renal Salvage (1A alluvial + 1B stacked bar + 1C line chart)
# Reference proportions: "Figure 1" y=10.43, panel letters y=10.047,
# plot top edge ~10.15 (letters just below), plots height ~2.75
fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  # 1A: Alluvial diagram (full-width, top)
  draw_grob(p1A, x = 0.5, y = 4.7+170/600+50/600, width = 7.5, height = 7.5 * (3493 / 5100)) +
  # 1B: Stacked bar (left, bottom)
  draw_plot(p1B, x = 0.5+1/6, y = 1.65+170/600+1/2-1/6, width = 3.6, height = 2.75) +
  # 1C: Line chart (right, bottom)
  draw_plot(p1C, x = 4.4-35/600-1/6, y = 1.65+170/600+1/2-1/6, width = 3.6, height = 2.75 + 18/600) +
  figure_labels(list(
    A          = c(0.645,     9.734+170/600),
    B          = c(0.645,     4.297+170/600+1/2-1/6),
    C          = c(4.153333,  4.297+170/600+1/2-1/6),
    "Figure 1" = c(0.49,      10.43)
  ))
#+ 7.3: Print PNG
print_to_png(fig1, "fig1.png", output_dir = "Outputs/Figures/Final/PNG")
