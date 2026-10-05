suppressPackageStartupMessages({
  library(gt)
  library(gtExtras)
  library(dplyr)
  library(readr)
})

df_chart2_raw <- readRDS("data/hpi_chart2.rds")

df_table <- df_chart2_raw %>%
  arrange(desc(hpi)) %>%
  mutate(
    footprint_bar = (footprint / max(footprint)) * 100,
    hpi_bar = hpi
  ) %>%
  select(
    country,
    continent,
    hpi,
    hpi_bar,
    life_exp,
    wellbeing,
    footprint,
    footprint_bar,
    gdp_pc
  )

tbl_hpi <- df_table %>%
  gt() %>%
  tab_header(
    title = md("**High National Income Fails to Guarantee Ecological Efficiency Across Global Economies**"),
    subtitle = "Benchmarking 25 representative economies across life expectancy, ladder-of-life wellbeing, and ecological footprint"
  ) %>%
  cols_label(
    country = "Country",
    continent = "Continent",
    hpi = "HPI Score",
    hpi_bar = "Efficiency Bar",
    life_exp = "Life Expectancy (Years)",
    wellbeing = "Wellbeing (0–10)",
    footprint = "Footprint (gha/capita)",
    footprint_bar = "Pressure Bar",
    gdp_pc = "GDP per Capita (USD)"
  ) %>%
  cols_width(
    country ~ px(130),
    continent ~ px(90),
    hpi ~ px(70),
    hpi_bar ~ px(100),
    life_exp ~ px(95),
    wellbeing ~ px(80),
    footprint ~ px(95),
    footprint_bar ~ px(100),
    gdp_pc ~ px(130)
  ) %>%
  fmt_number(
    columns = c(hpi, life_exp, wellbeing),
    decimals = 1
  ) %>%
  fmt_number(
    columns = c(footprint),
    decimals = 2
  ) %>%
  fmt_currency(
    columns = c(gdp_pc),
    currency = "USD",
    decimals = 0
  ) %>%
  gt_plt_bar_pct(
    column = hpi_bar,
    scaled = TRUE,
    fill = "#0072B2",
    background = "#EAEAEA",
    height = 14
  ) %>%
  gt_plt_bar_pct(
    column = footprint_bar,
    scaled = TRUE,
    fill = "#D55E00",
    background = "#EAEAEA",
    height = 14
  ) %>%
  gt_badge(
    column = continent,
    palette = c(
      "Americas" = "#56B4E9",
      "Oceania"  = "#CC79A7",
      "Europe"   = "#0072B2",
      "Asia"     = "#009E73",
      "Africa"   = "#E69F00"
    )
  ) %>%
  cols_align(
    align = "left",
    columns = c(country, continent)
  ) %>%
  cols_align(
    align = "center",
    columns = c(hpi, hpi_bar, footprint, footprint_bar)
  ) %>%
  cols_align(
    align = "right",
    columns = c(life_exp, wellbeing, gdp_pc)
  ) %>%
  tab_options(
    table.width = px(900),
    table.font.names = "sans-serif",
    table.font.size = px(13),
    heading.title.font.size = px(17),
    heading.title.font.weight = "bold",
    heading.subtitle.font.size = px(13),
    heading.align = "left",
    column_labels.font.size = px(12),
    column_labels.font.weight = "bold",
    column_labels.background.color = "#F4F6F9",
    row.striping.include_table_body = TRUE,
    row.striping.background_color = "#FAFAFA",
    table.border.top.style = "solid",
    table.border.top.color = "#333333",
    table.border.top.width = px(2),
    table.border.bottom.style = "solid",
    table.border.bottom.color = "#333333",
    table.border.bottom.width = px(2),
    data_row.padding = px(5)
  ) %>%
  tab_source_note(
    source_note = md("Source: Happy Planet Index 2024; World Bank Development Indicators. Table compiled for EPPS 6356 Chart Hackathon.")
  )

gtsave(tbl_hpi, "output/chart2_indicator_table.html")

tryCatch({
  gtsave(tbl_hpi, "output/chart2_indicator_table.png", vwidth = 1300, expand = 30)
  message("Chart 2 successfully rendered to output/chart2_indicator_table.html and .png")
}, error = function(e) {
  message("Chart 2 exported to HTML. (PNG export requires webshot2/chromote: install.packages('webshot2'))")
})