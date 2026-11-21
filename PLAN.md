# Project Plan — Unequal Discipline in Texas Public Schools

EPPS 6356 Data Visualization, Fall 2026 — Nedret Sen Cavus

## Assignment 9

### 1. Units and boundaries

- **One row of the map** is one Texas public school district (local education agency) in one school year. The static maps show the latest year (2023–24); the dashboard covers 2018–19 to 2023–24.
- **Boundaries** come from the U.S. Census Bureau cartographic (1:500k) school-district files for 2023, read with `tigris::school_districts(state = "TX", cb = TRUE, year = 2023)`. Unified districts are the main layer; elementary and secondary districts are added where the Census reports them for Texas.
- **Join key.** TEA identifies districts by a 6-digit county-district number (CDN). Census polygons use the 7-digit NCES LEAID (`GEOID`). The NCES Common Core of Data LEA directory (2022) links the two: its `state_leaid` (e.g., `TX-057905`) carries the CDN and its `leaid` equals the Census `GEOID`. The join is TEA CDN → CCD crosswalk → Census `GEOID`. Open-enrollment charter schools have no geographic boundary, so they remain unmatched by design; `maps.qmd` lists them with `anti_join()`.

### 2. Variables

All measures come from the TEA Annual District Discipline Summary (PEIMS), a long file with one row per district × `SECTION` × `HEADING_NAME` × `INDICATOR` and the number in `VALUE`. The denominators come from section A (cumulative year-end enrollment, overall and by race), which avoids the denominator neglect warned against in Cairo (2019).

| Variable | Type | Map form | Units | TEA rows used |
|---|---|---|---|---|
| Discretionary removals (ISS + OSS + discretionary DAEP actions) | rate | choropleth | actions per 100 enrolled students | Section B: In school suspensions, Out of school suspensions, Discretionary DAEP placements (action counts) ÷ Section A: Cumulative year end enrollment |
| Black students' discretionary removals | rate | choropleth (dashboard) | actions per 100 Black students | Sections C, D, E-Discretionary DAEP: Black or African American (action counts) ÷ Section A: Black or African American |
| White students' discretionary removals | rate | choropleth (dashboard) | actions per 100 White students | Same, White |
| Black-White risk ratio | index | choropleth (dashboard) | ratio (1 = parity) | Black rate ÷ White rate |
| Students with an in-school / out-of-school suspension | share | choropleth (dashboard) | % of enrolled students | Section B (student counts) ÷ enrollment |
| Discretionary DAEP removals | rate | choropleth (dashboard) | removals per 1,000 enrolled students | Section B: Discretionary DAEP placements (action counts) ÷ enrollment |
| Discretionary removal actions | count | proportional symbols | actions (number) | Section B action counts, summed |

TEA masks small values for student privacy (FERPA) with entries such as "<10" or "<20". These are coded as missing and shown in neutral grey with their own "No data" legend entry, never as zero. TEA prints no row when a category is zero, so absent rows are counted as 0.

### 3. Coordinate reference systems

- **Storage: EPSG:4326 (WGS 84 longitude/latitude).** It is the neutral exchange format: `tigris` boundaries are reprojected to it once and saved, so every later step starts from the same coordinates.
- **Static maps: EPSG:5070 (NAD83 / Conus Albers equal-area).** The assignment default for the contiguous U.S.; it keeps district areas proportional to land area, which a choropleth needs because readers compare colored areas.
- **Interactive map: EPSG:4326 in, EPSG:3857 (Web Mercator) on screen.** Leaflet expects longitude/latitude input and reprojects to Web Mercator to match its tiles; area distortion is acceptable there because users zoom and hover for exact values.

### 4. Interaction

Four inputs change the reactive map in the dashboard's **Map** page:

1. **Measure:** one of the seven rates, shares or indices above, including Black and White rates and the Black-White risk ratio.
2. **School year:** 2018–19 to 2023–24, so the COVID-19 disruption (2019–20, 2020–21) and the return to in-person school can be compared.
3. **Colour scale:** quantile (5 classes) vs. continuous.
4. **Minimum denominator:** rates computed from fewer students than the threshold are hidden (grey), so noisy small-group rates are not overinterpreted (Hullman 2020). Each measure is compared with its own denominator (all, Black, or White students).

One shared `reactive()` holds the filtered `sf` data. It feeds the Leaflet map (redrawn with `leafletProxy()`), three value boxes (districts shown, districts without a rate, median of the selected measure), and a companion top-10 dot plot drawn on a common scale from zero (Cleveland and McGill 1984).
