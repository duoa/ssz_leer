# Visualization Functions for Zurich Leerkündigungen Analysis
# This file contains functions to create visualizations for the analysis
# Reviewed: Angelo Duò, 03-02-2026

library(ggplot2)
library(dplyr)
library(scales)

# Color-blind friendly palette
CB_PALETTE <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7", "#999999")

#' Create temporal plot showing total affected count over time
#'
#' @param temporal_summary Data frame with year and total_affected columns
#' @param peak_years Vector of peak years to highlight
#' @return ggplot object
#' @export
plot_persons_per_time <- function(temporal_summary) {
  p <- ggplot(temporal_summary, aes(x = year, y = total_affected)) +
    geom_line(color = CB_PALETTE[5], size = 1.2) +
    geom_point(color = CB_PALETTE[5], size = 3) +
    labs(
      title = "Betroffene Personen über die Zeit",
      subtitle = "Leerkündigungen in Zürich",
      x = "Jahr",
      y = "Anzahl betroffene Personen"
    ) +
    scale_y_continuous(labels = comma) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank()
    )

  return(p)
}

#' Create composition plot showing residence outcomes over time
#'
#' @param composition_summary Data frame with year, new_residence, and share columns
#' @return ggplot object
#' @export
plot_composition_shift <- function(composition_summary) {
  # Create stacked area chart
  p <- ggplot(composition_summary, aes(x = year, y = share, fill = new_residence)) +
    geom_area(alpha = 0.7) +
    labs(
      title = "Zielort-Zusammensetzung über die Zeit",
      subtitle = "Verteilung der Zielorte nach Leerkündigung",
      x = "Jahr",
      y = "Anteil betroffene Personen",
      fill = "Zielort"
    ) +
    scale_y_continuous(labels = percent, expand = c(0, 0)) +
    scale_fill_manual(values = CB_PALETTE) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    ) +
    guides(fill = guide_legend(nrow = 2))

  return(p)
}


#' Create age-group comparison plot showing within-city shares
#' ToDo: refactor to one utility function 
#' @param age_summary Data frame with age_group and within_city_share columns
#' @return ggplot object
#' @export
plot_age_gradient <- function(age_summary) {
  p <- ggplot(age_summary, aes(x = reorder(age_group, within_city_share),
                              y = within_city_share)) +
    geom_col(fill = CB_PALETTE[3], alpha = 0.8) +
    geom_text(aes(label = paste0(round(within_city_share * 100, 1), "%")),
              hjust = -0.2, size = 4) +
    coord_flip() +
    labs(
      title = "Anteil innerhalb der Stadt nach Altersgruppe",
      subtitle = "Anteil der betroffenen Personen, die innerhalb der Stadt Zürich bleiben",
      x = "Altersgruppe",
      y = "Anteil innerhalb der Stadt"
    ) +
    scale_y_continuous(
      labels = percent,
      limits = c(0, max(age_summary$within_city_share) * 1.15)
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )

  return(p)
}


#' Create same-quarter comparison plot (if applicable)
#' ToDo: refactor with plot_age_gradient to one utility function 
#' @param same_quarter_summary Data frame with age_group and same_quarter_share columns
#' @return ggplot object
#' @export
plot_same_quarter <- function(same_quarter_summary) {
  p <- ggplot(same_quarter_summary, aes(x = reorder(age_group, same_quarter_share),
                                       y = same_quarter_share)) +
    geom_col(fill = CB_PALETTE[1], alpha = 0.8) +
    geom_text(aes(label = paste0(round(same_quarter_share * 100, 1), "%")),
              hjust = -0.2, size = 4) +
    coord_flip() +
    labs(
      title = "Anteil im gleichen Stadtquartier nach Altersgruppe",
      subtitle = "Anteil der betroffenen Personen, die im gleichen Stadtquartier bleiben",
      x = "Altersgruppe",
      y = "Anteil im gleichen Stadtquartier"
    ) +
    scale_y_continuous(
      labels = percent,
      limits = c(0, max(same_quarter_summary$same_quarter_share) * 1.15)
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )

  return(p)
}


#' Create unknown concentration plot 
#'
#' @param unknown_summary Data frame with age_group and unknown_share columns
#' @return ggplot object
#' @export
plot_unknown_concentration <- function(unknown_summary) {
  p <- ggplot(unknown_summary, aes(x = reorder(age_group, unknown_share),
                                  y = unknown_share)) +
    geom_col(fill = CB_PALETTE[8], alpha = 0.8) +
    geom_text(aes(label = paste0(round(unknown_share * 100, 1), "%")),
              hjust = -0.2, size = 4) +
    coord_flip() +
    labs(
      title = "Anteil „Unbekannt“ nach Altersgruppe",
      subtitle = "Anteil der betroffenen Personen mit unbekanntem Zielort",
      x = "Altersgruppe",
      y = "Anteil mit „Unbekannt“"
    ) +
    scale_y_continuous(
      labels = percent,
      limits = c(0, max(unknown_summary$unknown_share) * 1.15)
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )

  return(p)
}

#' Create heatmap of standardized residua (R) for age_group vs. new_residence.
#'
#' @param Rlong Long-format data frame of standardized residua, with factor columns
#'        `age_group` and `new_residence` already correctly ordered.
#' @return ggplot object
#' @export
plot_standardized_residua <- function(Rlong) {
  p <- ggplot(Rlong, aes(new_residence, age_group, fill = resid)) +
    geom_tile() +
    labs(
      title = "Standardisierte Residuen: Alter × Zielort",
      subtitle = "R = (O − E) / sqrt(E); >0 über-, <0 unterrepräsentiert",
      x = "Zielort (new_residence)",
      y = "Altersgruppe",
      fill = "Residuum"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40")
    ) +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red")
  
  return(p)
}

#' Create heatmap of log2(Relative Risk) for age_group vs. new_residence.
#'
#' @param log2RR_long Long-format data frame of log2(Relative Risk), with factor columns
#'        `age_group` and `new_residence` already correctly ordered.
#' @param cap Numeric value used to clip the log2RR scale for visualization.
#' @return ggplot object
#' @export
plot_log2_relative_risk <- function(log2RR_long, cap = 2.5) {
  p <- ggplot(log2RR_long, aes(new_residence, age_group, fill = log2RR)) +
    geom_tile() +
    labs(
      title = "log2(Relativrisiko): Über-/Unterrepräsentation Alter × Zielort",
      subtitle = "0 = durchschnittlich; +1 ≈ 2×; −1 ≈ 0.5× (Farbskala gekappt)",
      x = "Zielort (new_residence)",
      y = "Altersgruppe",
      fill = "log2(RR)"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40")
    ) +
    scale_fill_distiller(palette = "inferno", direction = 1, limits = c(-cap, cap))
    
  return(p)
}

