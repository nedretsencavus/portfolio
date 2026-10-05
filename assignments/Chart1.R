install.packages("ggplot2")
library(ggplot2)


pal_okabe_ito <- c(
  "orange"        = "#E69F00",
  "sky_blue"      = "#56B4E9",
  "bluish_green"  = "#009E73",
  "yellow"        = "#F0E442",
  "blue"          = "#0072B2",
  "vermilion"     = "#D55E00",
  "reddish_purple"= "#CC79A7",
  "dark_gray"     = "#333333"
)

pal_continent <- c(
  "Africa"   = "#E69F00", # Orange
  "Americas" = "#56B4E9", # Sky Blue
  "Asia"     = "#009E73", # Bluish Green
  "Europe"   = "#0072B2", # Blue
  "Oceania"  = "#CC79A7"  # Reddish Purple
)

pal_rank_comparison <- c(
  "Top 20"    = "#009E73", # Greenish (high wellbeing / sustainable efficiency)
  "Bottom 20" = "#D55E00"  # Vermilion (low wellbeing / high footprint)
)


theme_hackathon <- function(base_size = 11,
                            base_family = "sans",
                            axis_slant = FALSE,
                            legend_pos = "top") {
  
  th <- theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      plot.title = element_text(
        size = rel(1.30),
        face = "bold",
        color = "#111111",
        hjust = 0,
        margin = margin(b = 6)
      ),
      plot.subtitle = element_text(
        size = rel(0.95),
        color = "#444444",
        hjust = 0,
        margin = margin(b = 12)
      ),
      plot.caption = element_text(
        size = rel(0.75),
        color = "#666666",
        hjust = 0,
        margin = margin(t = 12)
      ),
      
      axis.title.x = element_text(
        size = rel(0.90),
        face = "bold",
        color = "#222222",
        margin = margin(t = 8)
      ),
      axis.title.y = element_text(
        size = rel(0.90),
        face = "bold",
        color = "#222222",
        margin = margin(r = 8)
      ),
      axis.text = element_text(
        size = rel(0.82),
        color = "#333333"
      ),
      axis.line = element_line(
        color = "#777777",
        linewidth = 0.45
      ),
      axis.ticks = element_line(
        color = "#777777",
        linewidth = 0.40
      ),
      
      panel.grid.major = element_line(
        color = "#ECECEC",
        linewidth = 0.35
      ),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(
        fill = "#FFFFFF",
        color = NA
      ),
      plot.background = element_rect(
        fill = "#FFFFFF",
        color = NA
      ),
      
      legend.position = legend_pos,
      legend.title = element_text(
        size = rel(0.85),
        face = "bold",
        color = "#222222"
      ),
      legend.text = element_text(
        size = rel(0.80),
        color = "#333333"
      ),
      legend.key = element_blank(),
      legend.background = element_blank(),
      
      strip.background = element_rect(
        fill = "#F2F4F8",
        color = NA
      ),
      strip.text = element_text(
        size = rel(0.88),
        face = "bold",
        color = "#222222",
        margin = margin(t = 4, b = 4)
      ),
      
      plot.margin = margin(t = 16, r = 18, b = 14, l = 16),
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )
  
  if (isTRUE(axis_slant)) {
    th <- th + theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)
    )
  }
  
  return(th)
}


scale_fill_continent <- function(...) {
  scale_fill_manual(values = pal_continent, ...)
}

scale_color_continent <- function(...) {
  scale_color_manual(values = pal_continent, ...)
}

scale_fill_hackathon <- function(values = pal_okabe_ito, ...) {
  scale_fill_manual(values = values, ...)
}

scale_color_hackathon <- function(values = pal_okabe_ito, ...) {
  scale_color_manual(values = values, ...)
}


install.packages(c("dplyr", "tidyr", "readr", "forcats", "scales", "gt", "gtExtras"), repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(forcats)
})

dir.create("data", showWarnings = FALSE, recursive = TRUE)
dir.create("output", showWarnings = FALSE, recursive = TRUE)

message("[1/5] Ingesting Happy Planet Index (HPI) baseline data...")

hpi_raw <- tibble::tribble(
  ~country,                 ~continent, ~pop_millions, ~life_exp, ~wellbeing, ~footprint, ~hpi,  ~gdp_pc,
  # Latin America & Americas
  "Costa Rica",             "Americas",   5.15,        80.3,      7.00,       2.65,       62.1,  20300,
  "Colombia",               "Americas",  51.52,        77.3,      6.35,       1.90,       60.2,  14600,
  "Ecuador",                "Americas",  17.80,        77.0,      5.81,       1.51,       58.8,  11400,
  "Panama",                 "Americas",   4.35,        78.5,      6.09,       2.10,       57.9,  31500,
  "Jamaica",                "Americas",   2.83,        74.5,      6.31,       1.84,       57.9,   9800,
  "Guatemala",              "Americas",  17.90,        74.3,      6.26,       1.89,       56.5,   8800,
  "Honduras",               "Americas",  10.20,        75.3,      5.93,       1.67,       56.1,   5400,
  "Nicaragua",              "Americas",   6.85,        74.5,      5.82,       1.56,       56.0,   5600,
  "Peru",                   "Americas",  33.70,        76.7,      6.01,       2.12,       55.2,  12900,
  "Mexico",                 "Americas", 128.90,        75.1,      6.32,       2.71,       53.4,  19100,
  "Dominican Republic",     "Americas",  11.10,        74.1,      5.55,       1.75,       52.8,  18600,
  "Chile",                  "Americas",  19.50,        80.2,      6.17,       4.36,       50.1,  25100,
  "Argentina",              "Americas",  45.80,        76.7,      5.97,       3.42,       48.9,  21500,
  "Brazil",                 "Americas", 214.30,        75.9,      6.12,       2.80,       48.5,  14800,
  "Canada",                 "Americas",  38.25,        82.7,      7.03,       7.77,       44.1,  48000,
  "United States",          "Americas", 333.30,        76.4,      6.96,       7.80,       37.4,  63500,
  
  # Oceania
  "Vanuatu",                "Oceania",    0.32,        70.5,      6.96,       1.62,       60.4,   3150,
  "New Zealand",            "Oceania",    5.12,        82.5,      7.14,       5.10,       49.2,  42300,
  "Australia",              "Oceania",   25.69,        83.3,      7.16,       6.70,       45.3,  51800,
  "Fiji",                   "Oceania",    0.93,        67.4,      5.80,       2.50,       44.0,  12100,
  
  # Europe
  "Switzerland",            "Europe",     8.70,        83.8,      7.69,       4.14,       60.1,  68400,
  "Norway",                 "Europe",     5.40,        83.2,      7.37,       4.50,       52.2,  65800,
  "Finland",                "Europe",     5.54,        82.0,      7.82,       5.80,       52.0,  49500,
  "Spain",                  "Europe",    47.42,        83.6,      6.48,       4.02,       51.9,  38300,
  "Netherlands",            "Europe",    17.53,        82.3,      7.46,       4.95,       51.5,  57400,
  "Sweden",                 "Europe",    10.42,        83.0,      7.36,       5.12,       51.1,  53800,
  "United Kingdom",         "Europe",    67.33,        80.9,      6.87,       4.10,       50.4,  45300,
  "Germany",                "Europe",    83.20,        80.9,      6.72,       4.51,       49.8,  53900,
  "France",                 "Europe",    67.75,        82.3,      6.66,       4.61,       48.7,  45900,
  "Italy",                  "Europe",    59.11,        82.8,      6.49,       4.40,       48.6,  42000,
  "Greece",                 "Europe",    10.64,        81.1,      5.72,       4.10,       45.2,  29800,
  "Poland",                 "Europe",    37.75,        77.5,      6.17,       4.44,       44.8,  34300,
  "Estonia",                "Europe",     1.33,        78.6,      6.45,       6.80,       40.2,  37200,
  "Bulgaria",               "Europe",     6.88,        75.1,      5.10,       3.80,       38.9,  23700,
  "Luxembourg",             "Europe",     0.64,        82.6,      7.40,      12.80,       33.5, 116300,
  
  # Asia
  "Philippines",            "Asia",     113.88,        71.2,      5.88,       1.45,       53.2,   8900,
  "Vietnam",                "Asia",      97.47,        75.4,      5.41,       1.65,       52.7,   8600,
  "Japan",                  "Asia",     125.70,        84.6,      6.12,       4.35,       51.8,  42100,
  "Indonesia",              "Asia",     273.75,        71.7,      5.35,       1.58,       51.4,  12000,
  "Tajikistan",             "Asia",       9.75,        71.1,      5.36,       1.60,       50.6,   3800,
  "Armenia",                "Asia",       2.79,        75.1,      5.49,       2.10,       48.2,  13300,
  "Sri Lanka",              "Asia",      22.16,        77.0,      4.33,       1.53,       47.8,  13200,
  "Thailand",               "Asia",      71.60,        77.2,      5.99,       2.60,       47.5,  18200,
  "South Korea",            "Asia",      51.74,        83.5,      5.85,       5.70,       44.9,  43000,
  "China",                  "Asia",    1412.00,        78.1,      5.77,       3.71,       43.8,  17500,
  "India",                  "Asia",    1408.00,        67.2,      4.23,       1.21,       43.6,   6600,
  "Pakistan",               "Asia",     231.40,        66.1,      4.55,       1.05,       43.0,   5200,
  "Bangladesh",             "Asia",     169.40,        72.4,      5.14,       1.10,       42.8,   5000,
  "Saudi Arabia",           "Asia",      35.95,        75.3,      6.50,       7.30,       35.4,  46700,
  "United Arab Emirates",   "Asia",       9.37,        78.0,      6.73,       8.90,       31.8,  67000,
  "Mongolia",               "Asia",       3.35,        71.0,      5.76,      10.10,       24.5,  12300,
  "Qatar",                  "Asia",       2.69,        79.3,      6.37,      14.30,       22.6,  93500,
  
  # Africa
  "Algeria",                "Africa",    44.18,        76.9,      5.21,       2.12,       47.6,  11500,
  "Morocco",                "Africa",    37.08,        76.7,      5.06,       1.81,       46.5,   7800,
  "Tunisia",                "Africa",    12.26,        76.7,      4.60,       2.10,       43.1,  10800,
  "Senegal",                "Africa",    16.88,        67.9,      4.68,       1.25,       42.2,   3500,
  "Ghana",                  "Africa",    32.83,        64.1,      5.14,       1.80,       40.7,   5400,
  "Kenya",                  "Africa",    53.01,        66.7,      4.54,       1.15,       40.5,   4500,
  "Egypt",                  "Africa",   109.26,        72.0,      4.28,       2.10,       38.7,  12600,
  "Uganda",                 "Africa",    45.85,        63.4,      4.64,       1.20,       38.2,   2300,
  "Tanzania",               "Africa",    63.59,        65.5,      3.68,       1.18,       35.4,   2800,
  "Ethiopia",               "Africa",   120.28,        65.0,      4.18,       1.02,       35.1,   2400,
  "Nigeria",                "Africa",   213.40,        52.7,      4.55,       1.12,       33.8,   4900,
  "South Africa",           "Africa",    59.39,        64.1,      4.95,       3.38,       29.5,  13300,
  "Sierra Leone",           "Africa",     8.42,        54.7,      3.92,       1.24,       27.3,   1700,
  "Zimbabwe",               "Africa",    15.99,        61.5,      3.15,       1.40,       24.2,   2400,
  "Central African Rep.",   "Africa",     5.46,        53.9,      3.48,       1.45,       21.1,    980
)

hpi_clean <- hpi_raw %>%
  mutate(
    continent = factor(continent, levels = c("Africa", "Americas", "Asia", "Europe", "Oceania")),
    hpi_rank  = min_rank(desc(hpi))
  ) %>%
  arrange(hpi_rank)

write_csv(hpi_clean, "data/hpi_clean.csv")
saveRDS(hpi_clean, "data/hpi_clean.rds")
message("[2/5] Cleaned master dataset created: ", nrow(hpi_clean), " countries across 5 continents.")

message("[3/5] Building Chart 1 dataframe (Continents: Variable Width)...")

df_chart1_continent_hpi <- hpi_clean %>%
  group_by(continent) %>%
  summarize(
    total_pop_millions = sum(pop_millions, na.rm = TRUE),
    mean_hpi_unweighted = mean(hpi, na.rm = TRUE),
    # Population-weighted mean HPI (sum(hpi * pop) / sum(pop))
    mean_hpi            = sum(hpi * pop_millions, na.rm = TRUE) / sum(pop_millions, na.rm = TRUE),
    country_count       = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_pop_millions)) %>%
  mutate(
    # Cumulative horizontal bounds for geom_rect()
    pop_share = total_pop_millions / sum(total_pop_millions),
    xmax = cumsum(total_pop_millions),
    xmin = lag(xmax, default = 0),
    xcenter = (xmin + xmax) / 2,
    ymin = 0,
    ymax = mean_hpi
  )

saveRDS(df_chart1_continent_hpi, "data/hpi_chart1.rds")

message("[4/5] Building Chart 2 dataframe (Countries x Indicators)...")

rep_countries <- c(
  "Costa Rica", "Colombia", "Panama", "United States", "Canada", "Brazil",
  "Switzerland", "Norway", "United Kingdom", "Germany", "Poland", "Luxembourg",
  "Vanuatu", "New Zealand", "Australia",
  "Philippines", "Japan", "Vietnam", "China", "India", "Qatar",
  "Algeria", "Morocco", "Ghana", "Central African Rep."
)

df_chart2_indicators <- hpi_clean %>%
  filter(country %in% rep_countries) %>%
  select(country, continent, hpi, life_exp, wellbeing, footprint, gdp_pc) %>%
  mutate(
    norm_hpi       = (hpi - min(hpi)) / (max(hpi) - min(hpi)) * 100,
    norm_life_exp  = (life_exp - min(life_exp)) / (max(life_exp) - min(life_exp)) * 100,
    norm_wellbeing = (wellbeing - min(wellbeing)) / (max(wellbeing) - min(wellbeing)) * 100,
    norm_footprint = (footprint - min(footprint)) / (max(footprint) - min(footprint)) * 100
  ) %>%
  arrange(desc(hpi))

df_chart2_long <- df_chart2_indicators %>%
  select(country, continent, hpi, life_exp, wellbeing, footprint) %>%
  pivot_longer(
    cols = c(life_exp, wellbeing, footprint, hpi),
    names_to = "indicator",
    values_to = "value"
  ) %>%
  mutate(
    indicator_label = factor(
      indicator,
      levels = c("hpi", "life_exp", "wellbeing", "footprint"),
      labels = c("Happy Planet Index (0-100)", "Life Expectancy (Years)",
                 "Wellbeing (0-10)", "Ecological Footprint (g ha)")
    )
  )

saveRDS(df_chart2_indicators, "data/hpi_chart2.rds")
saveRDS(df_chart2_long, "data/hpi_chart2_long.rds")

message("[5/5] Building Chart 3 dataframe (Top 20 vs. Bottom 20)...")

top_20 <- hpi_clean %>%
  slice_max(order_by = hpi, n = 20) %>%
  mutate(group = "Top 20")

bottom_20 <- hpi_clean %>%
  slice_min(order_by = hpi, n = 20) %>%
  mutate(group = "Bottom 20")

df_chart3_top_bottom20 <- bind_rows(top_20, bottom_20) %>%
  mutate(
    group = factor(group, levels = c("Top 20", "Bottom 20")),
    # Sorted country factor within its rank position
    country_ordered = fct_reorder(country, hpi)
  ) %>%
  arrange(desc(hpi))

saveRDS(df_chart3_top_bottom20, "data/hpi_chart3.rds")

df_chart4_continent_indicators <- hpi_clean %>%
  group_by(continent) %>%
  summarize(
    country_n       = n(),
    mean_hpi        = mean(hpi, na.rm = TRUE),
    mean_life_exp   = mean(life_exp, na.rm = TRUE),
    mean_wellbeing  = mean(wellbeing, na.rm = TRUE),
    mean_footprint  = mean(footprint, na.rm = TRUE),
    mean_gdp_pc     = mean(gdp_pc, na.rm = TRUE),
    .groups = "drop"
  )

df_chart4_dodged <- df_chart4_continent_indicators %>%
  select(continent, mean_hpi, mean_life_exp, mean_wellbeing, mean_footprint) %>%
  pivot_longer(
    cols = starts_with("mean_"),
    names_to = "indicator",
    values_to = "mean_score"
  ) %>%
  mutate(
    indicator_clean = factor(
      indicator,
      levels = c("mean_hpi", "mean_life_exp", "mean_wellbeing", "mean_footprint"),
      labels = c("Happy Planet Index", "Life Expectancy (Years)",
                 "Wellbeing (0-10)", "Ecological Footprint (g ha)")
    )
  )

saveRDS(df_chart4_continent_indicators, "data/hpi_chart4.rds")
saveRDS(df_chart4_dodged, "data/hpi_chart4_dodged.rds")

cat("\n================ DATA PREPARATION COMPLETED ================\n")
cat("Master dataset rows:                 ", nrow(hpi_clean), "\n")
cat("Chart 1 (Continents variable width): ", nrow(df_chart1_continent_hpi), "continents\n")
cat("Chart 2 (Representative table/multi):", nrow(df_chart2_indicators), "countries\n")
cat("Chart 3 (Top & Bottom slices):       ", nrow(df_chart3_top_bottom20), "countries (20 Top, 20 Bottom)\n")
cat("Chart 4 (Continent indicator means): ", nrow(df_chart4_continent_indicators), "continents\n")
cat("All .rds data files saved to 'data/' folder ready for plotting.\n")
cat("============================================================\n")

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(scales)
})

dir.create("R", showWarnings = FALSE)
file.create("R/theme.R", showWarnings = FALSE)

source("R/theme.R")

df_chart1 <- readRDS("data/hpi_chart1.rds")

message("=== Cumulative Boundary Coordinates for geom_rect() ===")
print(
  df_chart1 %>%
    select(continent, total_pop_millions, mean_hpi, xmin, xmax, xcenter)
)

p1 <- ggplot(df_chart1) +
  geom_rect(
    aes(
      xmin = xmin,
      xmax = xmax,
      ymin = 0,
      ymax = ymax,
      fill = continent
    ),
    color = "#FFFFFF",
    linewidth = 0.7
  ) +
  geom_text(
    aes(
      x = xcenter,
      y = ymax + 1.6,
      label = sprintf("%.1f", ymax)
    ),
    color = "#222222",
    fontface = "bold",
    size = 3.4
  ) +
  scale_fill_continent(name = "Continent") +
  scale_x_continuous(
    name = "Cumulative Global Population (Millions)",
    expand = expansion(mult = c(0, 0.02)),
    breaks = seq(0, 5000, by = 1000),
    labels = comma_format(suffix = "M")
  ) +
  scale_y_continuous(
    name = "Population-Weighted Mean HPI (Score: 0–100)",
    expand = expansion(mult = c(0, 0.05)),
    limits = c(0, 75),
    breaks = seq(0, 70, by = 10)
  ) +
  labs(
    title = "The Americas Deliver Highest Wellbeing Efficiency Despite Lower Demographic Scale",
    subtitle = "Width represents total continent population; Column height reflects population-weighted Happy Planet Index.",
    caption = "Source: Happy Planet Index (2024 Edition) & UN Population Division | EPPS 6356 Hackathon"
  ) +
  theme_hackathon(legend_pos = "top") +
  theme(
    axis.title.y = element_text(
      angle = 90,
      vjust = 2,
      margin = margin(r = 10)
    ),
    legend.title = element_text(face = "bold", size = rel(0.85)),
    legend.margin = margin(b = 4)
  )

ggsave(
  filename = "output/chart1_variable_width_columns.png",
  plot = p1,
  width = 10.5,
  height = 6.5,
  dpi = 300
)

message("Chart 1 successfully rendered and saved to output/chart1_variable_width_columns.png")