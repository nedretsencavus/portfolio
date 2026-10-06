# AI Disclosure — EPPS 6356 Assignment 4 (Chart Hackathon)

Per the assignment rule *"AI is allowed, with disclosure. For each chart, record the
tool, model and version, date, and full prompts, plus two or three sentences on what
you had to fix in the AI's output."*

Each team member documents their own charts below.

---

## Chart 4 — Column chart: mean HPI by continent
**Author:** Shao-Kang (Eric) Huang
**Tool:** Claude (Anthropic), model `claude-opus-5`, used in the Claude desktop app
**Date:** 5 October 2026
**Files produced:** `assignments/Chart4.R`, `R/theme.R`,
`data/hpi_chart4_means.rds`, `output/chart4_continent_means.png`

### Prompts

The conversation was held in Traditional Chinese. The prompts that produced the
committed code are reproduced below with English translations.

1. > 接著幫我依照他的風格完成第四張圖
   > *(Now complete the fourth chart for me, following her style.)*

   Context supplied to the model beforehand: the assignment PDF, the teammate's
   published page `https://nedretsencavus.github.io/portfolio/assignments/assign04.html`,
   and read access to this repository after it was cloned locally — in particular
   `assignments/Chart3.R`, `assignments/assign04.qmd`, and `data/hpi_clean.csv`.

2. > 幫我看一下
   > *(Take a look at this for me.)* — sent with the first rendered PNG, which
   > asked the model to review the output against the other three charts.

### What I had to fix in the AI's output

- **The y-axis title came out horizontal.** `theme_hackathon()` re-declares
  `axis.title.y` through `%+replace%` without an `angle`, so the angle resets to 0,
  the title is printed flat at the far left, and the panel is squeezed. I caught this
  when I compared the first render against Chart 1, where the same fix
  (`element_text(angle = 90, vjust = 2, margin = margin(r = 10))`) already appears.
  The model had not carried that line over; it was added in commit `07f074f`.
- **The first draft of the commit would have touched the whole repository.** Because
  the clone is on a Windows machine, every text file in the repo showed as modified
  on line endings alone (13,521 insertions / 13,527 deletions across 52 files, all
  whitespace). I staged only the four new paths instead of using `git add -A`, so the
  commit history stays readable.
- **`source("R/theme.R")` pointed at a file that was not in the repository.**
  `Chart1.R` and `Chart3.R` both call it, but the theme existed only inside the setup
  chunk of `assign04.qmd`, so those two scripts failed from a clean R session. I had
  the palettes and `theme_hackathon()` extracted into `R/theme.R` and verified that all
  four chart scripts now run from the project root, which is what the checklist item
  *"code runs from a clean R session using only the repo contents"* requires.

### Design decisions that are mine, not the model's

- Sorting the continents by mean HPI rather than alphabetically, so the chart answers
  its own title.
- Printing `n =` inside each column. Oceania's mean rests on four countries and
  Asia's on seventeen; without the counts the five columns read as equally reliable.
- Stating the mean is **unweighted** in the subtitle, since Chart 1 uses a
  population-weighted mean and the two numbers would otherwise appear to disagree.

---

## Charts 1–3

*(Nedret: please add your tool, model, date, prompts and fixes here. If a chart was
written without AI assistance, say so explicitly — the rule asks for disclosure
either way.)*
