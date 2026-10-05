## EPPS 6356 Chart Hackathon - Chart 4: Column chart (one variable, few items)
## Shao-Kang (Eric) Huang
##
## Abela's Thought-Starter, Comparison branch: one variable across a few items.
## Mean Happy Planet Index by continent, 2024.
## Run from the project root: source("assignments/Chart4.R")

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(forcats)
  library(scales)
})

source("R/theme.R")          # shared palette + theme_hackathon()

hpi_clean <- readRDS("data/hpi_clean.rds")

## ---- data ------------------------------------------------------------------
## Few items (five continents), one variable (mean HPI). The count of countries
## behind each mean is carried through so the chart can state its own n.
df_chart4 <- hpi_clean %>%
  group_by(continent) %>%
  summarise(
    mean_hpi = mean(hpi, na.rm = TRUE),
    n        = dplyr::n(),
    .groups  = "drop"
  ) %>%
  mutate(continent_ordered = fct_reorder(continent, mean_hpi, .desc = TRUE))

saveRDS(df_chart4, "data/hpi_chart4_means.rds")

## ---- chart -----------------------------------------------------------------
p4 <- ggplot(df_chart4, aes(x = continent_ordered, y = mean_hpi, fill = continent)) +
  geom_col(width = 0.68, show.legend = FALSE) +
  geom_text(
    aes(label = sprintf("%.1f", mean_hpi)),
    vjust = -0.55,
    size = 3.6,
    fontface = "bold",
    color = "#222222"
  ) +
  geom_text(
    aes(y = 1.8, label = paste0("n = ", n)),
    size = 2.9,
    color = "#FFFFFF",
    fontface = "bold"
  ) +
  scale_fill_continent() +
  scale_x_discrete(name = "Continent") +
  scale_y_continuous(
    name   = "Mean Happy Planet Index Score (0-100 Scale)",
    limits = c(0, 62),
    breaks = seq(0, 60, by = 10),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title    = "The Americas Convert Resources into Wellbeing More Efficiently Than Any Other Continent",
    subtitle = "Unweighted mean Happy Planet Index of the countries in each continent; n gives the number of countries behind each column.",
    caption  = "Source: Happy Planet Index (2024 Edition) | EPPS 6356 Hackathon"
  ) +
  theme_hackathon(legend_pos = "none") +
  theme(
    # theme_hackathon() resets axis.title.y without an angle, which leaves the
    # y title horizontal and squeezes the panel; the same fix is used in Chart1.R
    axis.title.y = element_text(angle = 90, vjust = 2, margin = margin(r = 10))
  )

p4

ggsave(
  filename = "output/chart4_continent_means.png",
  plot     = p4,
  width    = 10.5,
  height   = 6.5,
  dpi      = 300
)
