suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(forcats)
  library(scales)
})

source("R/theme.R")

df_chart3_raw <- readRDS("data/hpi_chart3.rds")

df_chart3 <- df_chart3_raw %>%
  mutate(
    # fct_reorder sorts factor levels by numeric value (ascending for horizontal display)
    country_ordered = fct_reorder(country, hpi),
    group = factor(group, levels = c("Top 20", "Bottom 20"))
  )

p3 <- ggplot(df_chart3, aes(x = hpi, y = country_ordered, fill = group)) +
  geom_col(
    width = 0.72,
    show.legend = FALSE
  ) +
  geom_text(
    aes(label = sprintf("%.1f", hpi)),
    hjust = -0.20,
    size = 3.1,
    fontface = "bold",
    color = "#222222"
  ) +
  facet_wrap(
    ~ group,
    scales = "free_y",
    ncol = 2
  ) +
  scale_fill_manual(
    values = c(
      "Top 20"    = "#0072B2",  # Okabe-Ito Blue (replaces bluish-green)
      "Bottom 20" = "#D55E00"   # Okabe-Ito Vermilion
    )
  ) +
  scale_x_continuous(
    name = "Happy Planet Index Score (0–100 Scale)",
    limits = c(0, 74),
    breaks = seq(0, 70, by = 10),
    expand = expansion(mult = c(0, 0.02))
  ) +
  scale_y_discrete(
    name = "Country"
  ) +
  labs(
    title = "Latin American Nations Lead Sustainable Efficiency While Fossil Rentiers and Fragile States Lag",
    subtitle = "Comparing the 20 highest- and 20 lowest-ranked global economies on the 2024 Happy Planet Index.",
    caption = "Source: Happy Planet Index (2024 Edition) | EPPS 6356 Hackathon"
  ) +
  theme_hackathon(legend_pos = "none") +
  theme(
    axis.text.y = element_text(size = rel(0.78), color = "#222222"),
    panel.spacing = unit(1.5, "lines"),
    strip.text = element_text(size = rel(0.95), face = "bold")
  )

ggsave(
  filename = "output/chart3_top_bottom20_bars.png",
  plot = p3,
  width = 11.5,
  height = 7.5,
  dpi = 300
)

message("Chart 3 successfully rendered to output/chart3_top_bottom20_bars.png")