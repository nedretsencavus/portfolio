## Shared design system for the EPPS 6356 Chart Hackathon
## Extracted from the setup chunk of assignments/assign04.qmd so that the
## standalone Chart scripts can source() it from a clean R session.
## (Chart1.R and Chart3.R already call source("R/theme.R"); this file supplies it.)

## ---- palettes --------------------------------------------------------------
pal_okabe_ito <- c(
  "orange"         = "#E69F00",
  "sky_blue"       = "#56B4E9",
  "bluish_green"   = "#009E73",
  "yellow"         = "#F0E442",
  "blue"           = "#0072B2",
  "vermilion"      = "#D55E00",
  "reddish_purple" = "#CC79A7",
  "dark_gray"      = "#333333"
)

pal_continent <- c(
  "Africa"   = "#E69F00",  # Orange
  "Americas" = "#56B4E9",  # Sky Blue
  "Asia"     = "#009E73",  # Bluish Green
  "Europe"   = "#0072B2",  # Blue
  "Oceania"  = "#CC79A7"   # Reddish Purple
)

pal_rank_comparison <- c(
  "Top 20"    = "#009E73",
  "Bottom 20" = "#D55E00"
)

## ---- scale helpers ---------------------------------------------------------
scale_fill_continent  <- function(...) ggplot2::scale_fill_manual(values = pal_continent, ...)
scale_color_continent <- function(...) ggplot2::scale_color_manual(values = pal_continent, ...)
scale_fill_hackathon  <- function(values = pal_okabe_ito, ...) ggplot2::scale_fill_manual(values = values, ...)
scale_color_hackathon <- function(values = pal_okabe_ito, ...) ggplot2::scale_color_manual(values = values, ...)

## ---- theme -----------------------------------------------------------------
theme_hackathon <- function(base_size = 11,
                            base_family = "sans",
                            axis_slant = FALSE,
                            legend_pos = "top") {

  th <- ggplot2::theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = ggplot2::rel(1.30), face = "bold",
                                         color = "#111111", hjust = 0,
                                         margin = ggplot2::margin(b = 6)),
      plot.subtitle = ggplot2::element_text(size = ggplot2::rel(0.95), color = "#444444",
                                            hjust = 0, margin = ggplot2::margin(b = 12)),
      plot.caption = ggplot2::element_text(size = ggplot2::rel(0.75), color = "#666666",
                                           hjust = 0, margin = ggplot2::margin(t = 12)),
      axis.title.x = ggplot2::element_text(size = ggplot2::rel(0.90), face = "bold",
                                           color = "#222222", margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(size = ggplot2::rel(0.90), face = "bold",
                                           color = "#222222", margin = ggplot2::margin(r = 8)),
      axis.text  = ggplot2::element_text(size = ggplot2::rel(0.82), color = "#333333"),
      axis.line  = ggplot2::element_line(color = "#777777", linewidth = 0.45),
      axis.ticks = ggplot2::element_line(color = "#777777", linewidth = 0.40),
      panel.grid.major = ggplot2::element_line(color = "#ECECEC", linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "#FFFFFF", color = NA),
      plot.background  = ggplot2::element_rect(fill = "#FFFFFF", color = NA),
      legend.position  = legend_pos,
      legend.title = ggplot2::element_text(size = ggplot2::rel(0.85), face = "bold", color = "#222222"),
      legend.text  = ggplot2::element_text(size = ggplot2::rel(0.80), color = "#333333"),
      legend.key = ggplot2::element_blank(),
      legend.background = ggplot2::element_blank(),
      strip.background = ggplot2::element_rect(fill = "#F2F4F8", color = NA),
      strip.text = ggplot2::element_text(size = ggplot2::rel(0.88), face = "bold",
                                         color = "#222222",
                                         margin = ggplot2::margin(t = 4, b = 4)),
      plot.margin = ggplot2::margin(t = 16, r = 18, b = 14, l = 16),
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )

  if (isTRUE(axis_slant)) {
    th <- th + ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, vjust = 1)
    )
  }
  th
}
