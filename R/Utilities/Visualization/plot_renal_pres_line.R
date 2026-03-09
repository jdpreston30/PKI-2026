#' Line Chart: Renal Salvage % by AAST Grade and Management Group
#'
#' Creates a connected dot-line chart of renal salvage percentage across AAST
#' grades (III, IV, V) for each index management strategy (CM, IR, OR).
#' Shares the same framed border aesthetic as `plot_renal_pres_stacked()`.
#'
#' @param data A tibble with columns: `index_group` (fct: CM/IR/OR),
#'   `AAST Grade` (fct: III/IV/V), `` `Renal Salvage (%%)` `` (dbl).
#'
#' @return A ggplot object.
#'
#' @examples
#' p <- plot_renal_pres_line(renal_pres_table)
#' ggsave("Outputs/Figures/F2_renal_pres_line.pdf", p, width = 5, height = 4, device = cairo_pdf)
plot_renal_pres_line <- function(data) {
  strategy_colors <- c("CM" = "black", "IR" = "#E5B87D", "OR" = "#8B9EC0")
  strategy_levels <- c("CM", "IR", "OR")

  plot_data <- data |>
    mutate(index_group = factor(index_group, levels = strategy_levels))

  pd <- position_dodge(width = 0.15)

  ggplot(plot_data, aes(
    x = `AAST Grade`,
    y = `Renal Salvage (%%)`,
    color = index_group,
    group = index_group
  )) +
    geom_line(linewidth = 0.7, position = pd) +
    geom_point(size = 2.5, position = pd) +
    scale_color_manual(
      values = strategy_colors,
      name = "Management\nStrategy",
      breaks = strategy_levels
    ) +
    scale_y_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, by = 25),
      expand = expansion(add = c(5, 5))
    ) +
    scale_x_discrete(expand = c(0.1, 0.1)) +
    labs(y = "Renal Salvage (%)", x = "AAST Grade") +
    theme_classic(base_family = "Arial") +
    theme(
      # No outer box — match panel.border only like plot A
      plot.background = element_blank(),
      # Panel border – same weight as A
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
      # Axes – fully consistent with A
      axis.line = element_blank(),
      axis.ticks = element_line(color = "black", linewidth = 0.6),
      axis.text = element_text(family = "Arial", size = 9, color = "black", face = "bold"),
      axis.title.y = element_text(family = "Arial", size = 10, face = "bold", margin = margin(r = 8)),
      axis.title.x = element_text(family = "Arial", size = 10, face = "bold", margin = margin(t = 8)),
      # Legend (right side, dot+line key)
      legend.position = "right",
      legend.title = element_text(family = "Arial", size = 9, face = "bold"),
      legend.text = element_text(family = "Arial", size = 9, face = "bold"),
      legend.key = element_blank(),
      legend.key.width = unit(0.45, "cm"),
      legend.key.height = unit(0.45, "cm"),
      # Margins
      plot.margin = margin(8, 8, 8, 8)
    ) +
    guides(color = guide_legend(override.aes = list(linewidth = 0.7, size = 2.5)))
}
