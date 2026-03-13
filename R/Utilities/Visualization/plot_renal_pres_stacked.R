#' Stacked Bar Chart: Renal Salvage by AAST Grade and Management Group
#'
#' Creates a stacked bar chart of renal salvage counts (Y/N) faceted by
#' index management group (CM, IR, OR) with bars per AAST grade (III, IV, V).
#' N (not preserved) stacked on top in red; Y (preserved) on bottom in blue.
#'
#' @param data A tibble with columns: `index_group` (fct: CM/IR/OR),
#'   `AAST Grade` (fct: III/IV/V), `Y` (int), `N` (int).
#'
#' @return A ggplot object.
#'
#' @examples
#' p <- plot_renal_pres_stacked(renal_pres_table)
#' ggsave("Outputs/Figures/F1_renal_pres.pdf", p, width = 6, height = 4)
plot_renal_pres_stacked <- function(data) {
  plot_data <- data |>
    select(index_group, `AAST Grade`, Y, N) |>
    pivot_longer(cols = c(Y, N), names_to = "Salvage", values_to = "Count") |>
    mutate(Salvage = factor(Salvage, levels = c("N", "Y")))
  # Y = bottom (blue), N = top (red); reverse = TRUE flips stack so N is on top
  salvage_colors <- c("Y" = "#8B9EC0", "N" = "#A35346")

  ggplot(plot_data, aes(x = `AAST Grade`, y = Count, fill = Salvage)) +
    geom_col(
      color = "black",
      linewidth = 0.2,
      width = 0.675,
      position = position_stack(reverse = TRUE)
    ) +
    geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
    facet_wrap(~ index_group, nrow = 1) +
    scale_fill_manual(
      values = salvage_colors,
      name = "Renal\nSalvage",
      breaks = c("Y", "N"),
      labels = c("Y", "N")
    ) +
    scale_y_continuous(
      limits = c(0, 40),
      breaks = seq(0, 40, by = 10),
      expand = expansion(add = c(2, 2))
    ) +
    scale_x_discrete(expand = c(0.2, 0.2)) +
    labs(y = "Patients (n)", x = "AAST Grade") +
    theme_classic(base_family = "Arial") +
    theme(
      # Negative spacing = -0.8pt forces full overlap of touching 0.8pt borders
      # so internal separators render at same weight as the outer frame.
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
      panel.spacing = unit(-0.8, "pt"),
      plot.background = element_blank(),
      # Strip inside panel: transparent background so top border isn't masked
      strip.background = element_blank(),
      strip.text = element_text(family = "Arial", size = 10, face = "bold",
                                margin = margin(t = 3, b = -14)),
      strip.clip = "off",
      # Axes
      axis.line = element_blank(),
      axis.ticks = element_line(color = "black", linewidth = 0.6),
      axis.text = element_text(family = "Arial", size = 9, color = "black", face = "bold"),
      axis.title.y = element_text(family = "Arial", size = 10, face = "bold", margin = margin(r = 8)),
      axis.title.x = element_text(family = "Arial", size = 10, face = "bold", margin = margin(t = 8)),
      # Legend – key border matches bar segment border (linewidth 0.4)
      legend.title = element_text(family = "Arial", size = 9, face = "bold"),
      legend.text = element_text(family = "Arial", size = 9, face = "bold"),
      legend.key = element_blank(),
      legend.key.size = unit(0.45, "cm"),
      # Margins
      plot.margin = margin(8, 8, 8, 8)
    ) +
    guides(fill = guide_legend(override.aes = list(linewidth = 0.2, color = "black")))
}
