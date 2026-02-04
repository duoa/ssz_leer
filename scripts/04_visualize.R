# Visualization Functions for Zurich Leerkündigungen Analysis
# This file contains functions to create visualizations for the analysis

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
      title = "Total Affected Persons Over Time",
      subtitle = "Leerkündigungen in Zurich",
      x = "Year",
      y = "Total Affected Persons"
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
#' @param deviant_years Vector of deviant years to highlight (optional)
#' @return ggplot object
#' @export
plot_composition_shift <- function(composition_summary, deviant_years = NULL) {
  # Create stacked area chart
  p <- ggplot(composition_summary, aes(x = year, y = share, fill = new_residence)) +
    geom_area(alpha = 0.8) +
    labs(
      title = "Residence Composition Over Time",
      subtitle = "Distribution of new residence outcomes after Leerkündigung",
      x = "Year",
      y = "Share of Affected Persons",
      fill = "New Residence"
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
  
  # Add vertical lines for deviant years if provided
  if (!is.null(deviant_years) && length(deviant_years) > 0) {
    p <- p +
      geom_vline(xintercept = deviant_years, 
                 linetype = "dashed", color = "red", alpha = 0.5)
  }
  
  return(p)
}

#' Create age-group comparison plot showing within-city shares
#'
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
      title = "Within-City Share by Age Group",
      subtitle = "Percentage of affected persons remaining within Zurich city",
      x = "Age Group",
      y = "Share Remaining Within City"
    ) +
    scale_y_continuous(labels = percent, limits = c(0, max(age_summary$within_city_share) * 1.15)) +
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
#'
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
      title = "Same City Quarter Share by Age Group",
      subtitle = "Percentage of affected persons remaining in the same city quarter",
      x = "Age Group",
      y = "Share Remaining in Same Quarter"
    ) +
    scale_y_continuous(labels = percent, limits = c(0, max(same_quarter_summary$same_quarter_share) * 1.15)) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  return(p)
}

#' Create unknown concentration plot (if applicable)
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
      title = "Unknown Residence Share by Age Group",
      subtitle = "Percentage of affected persons with unknown new residence",
      x = "Age Group",
      y = "Share with Unknown Residence"
    ) +
    scale_y_continuous(labels = percent, limits = c(0, max(unknown_summary$unknown_share) * 1.15)) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  return(p)
}
