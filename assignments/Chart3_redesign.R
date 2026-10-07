# Chart 3 Redesign
# Top and Bottom 20 countries by Happy Planet Index

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(forcats)
  library(scales)
})

source("../R/theme.R")

df_chart3_raw <- readRDS("../data/hpi_chart3.rds")
df_chart3 <- df_chart3_raw %>%
  mutate(
    group = factor(
      group,
      levels = c("Bottom 20", "Top 20")
    ),
    country_ordered = fct_reorder(country, hpi)
  )
hpi_gap <- max(df_chart3$hpi, na.rm = TRUE) -
  min(df_chart3$hpi, na.rm = TRUE)
p3_redesign <- ggplot(
  df_chart3,
  aes(
    x = hpi,
    y = country_ordered,
    fill = group
  )
) +
  geom_col(
    width = 0.72
  ) +
  geom_hline(
    yintercept = 20.5,
    linewidth = 0.5,
    color = "#999999"
  ) +
  geom_text(
    aes(label = sprintf("%.1f", hpi)),
    hjust = -0.15,
    size = 3
  ) +
  scale_fill_manual(
    values = pal_rank_comparison,
    breaks = c("Top 20", "Bottom 20")
  ) +
  scale_x_continuous(
    limits = c(0, 68),
    breaks = seq(0, 60, by = 10),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = sprintf(
      "A %.0f-point gap separates the highest and lowest HPI countries",
      hpi_gap
    ),
    subtitle = "Top and bottom 20 countries ranked by 2024 Happy Planet Index score", 
    x = "Happy Planet Index score",
    y = NULL,
    fill = NULL,
    caption = "Source: Happy Planet Index, 2024 edition"
  ) +
  theme_hackathon(
    base_size = 11,
    legend_pos = "top"
  ) +
  theme(
    legend.justification = "left",
    legend.box.just = "left",
    panel.grid.major.y = element_blank()
  )
p3_redesign
ggsave(
  filename = "../output/chart3_redesign.png",
  plot = p3_redesign,
  width = 10,
  height = 8,
  dpi = 300
)
