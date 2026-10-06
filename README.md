# EPPS 6356 — Assignment 4: Chart Producing Hackathon

Visualising the **Happy Planet Index (2024 edition)** with charts 1–4 of Andrew
Abela's *Chart Suggestions — A Thought-Starter*.

**Team:** Nedret Sen-Cavus (coordinator), Anugraha Samuel Gloria, Shao-Kang (Eric) Huang
**Course:** EPPS 6356 Data Visualization, Dr. Karl Ho, Fall 2026
**Published page:** <https://nedretsencavus.github.io/portfolio/assignments/assign04.html>

## The four charts

| # | Abela type | Question it answers | Script | Figure |
|---|---|---|---|---|
| 1 | Variable-width column | Two variables per item | `assignments/Chart1.R` | `output/chart1_variable_width_columns.png` |
| 2 | Table with embedded charts | Many categories | `assignments/Chart2.R` | `output/chart2_indicator_table.png` |
| 3 | Bar chart | One variable, many items | `assignments/Chart3.R` | `output/chart3_top_bottom20_bars.png` |
| 4 | Column chart | One variable, few items | `assignments/Chart4.R` | `output/chart4_continent_means.png` |

## Reproducing the charts

From a clean R session, with the working directory set to the project root
(open `portfolio.Rproj` in RStudio):

```r
source("assignments/Chart1.R")
source("assignments/Chart2.R")
source("assignments/Chart3.R")
source("assignments/Chart4.R")
```

Each script sources `R/theme.R` first, which defines the shared palette and
`theme_hackathon()`, then reads its data from `data/` and writes its figure to
`output/`. Rendering the whole site instead:

```r
quarto::quarto_render()
```

### Required packages

`ggplot2`, `dplyr`, `tidyr`, `forcats`, `scales`, `gt`, `gtExtras`

## Repository layout

```
R/theme.R              shared palette, scale helpers and theme_hackathon()
assignments/           one script per chart, plus assign04.qmd (the report)
data/                  the cleaned HPI extract and the per-chart datasets
output/                exported figures
docs/                  the rendered site (GitHub Pages serves this folder)
prompts.md             AI disclosure, per the assignment rule
sessionInfo.txt        the R session the figures were produced in
```

## Data

Happy Planet Index, 2024 edition — <https://happyplanetindex.org/countries/>.
The cleaned extract used here is `data/hpi_clean.csv` (67 countries; columns:
country, continent, pop_millions, life_exp, wellbeing, footprint, hpi, gdp_pc,
hpi_rank), saved alongside as `data/hpi_clean.rds`.

## Design system

One theme across all four charts: `theme_hackathon()` on a white panel with
`#ECECEC` gridlines, takeaway titles, axis titles carrying units, and a source
caption on every figure. Colours come from the Okabe-Ito colour-blind-safe
palette, with a fixed continent mapping so a continent keeps its colour from one
chart to the next.
