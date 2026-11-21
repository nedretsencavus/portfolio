# =============================================================================
# R/map_data_functions.R
# Helper functions for Assignment 9 (EPPS 6356, Fall 2026) — Nedret Sen Cavus
# Sourced by R/prepare_map_data.R. Not meant to be run on its own.
#
# Data sources (all primary public administrative repositories):
#   * TEA, Annual District Discipline Summary (PEIMS Summer submission),
#     "Discipline Summary Download" -> "Annual District Summary" (CSV).
#   * U.S. Census Bureau cartographic (1:500k) school-district boundaries,
#     read with tigris::school_districts() (Lovelace et al., ch. 2, sf objects).
#   * NCES Common Core of Data (CCD) LEA directory, served by the Urban
#     Institute Education Data API, used ONLY as an ID crosswalk:
#     TEA 6-digit county-district number (CDN) -> 7-digit NCES LEAID,
#     which is the GEOID in the Census school-district files.
# =============================================================================

# ---- TEA rows used in this assignment ---------------------------------------
# The TEA file is long: one row per district x SECTION x HEADING_NAME x
# INDICATOR, with the number in VALUE. Labels below are copied from the
# 2018-19 file (sections are matched by their letter prefix plus title).
tea_items <- tibble::tribble(
  ~var,              ~section_pattern,             ~heading,                          ~indicator,
  # Denominators (Cairo 2019: rates, not raw counts)
  "enrolled",        "^A-",                        "CUMULATIVE YEAR END ENROLLMENT",  "STUDENT COUNTS",
  "enr_black",       "^A-",                        "BLACK OR AFRICAN AMERICAN",       "STUDENT COUNTS",
  "enr_white",       "^A-",                        "WHITE",                           "STUDENT COUNTS",
  # All students
  "iss_actions",     "^B-",                        "IN SCHOOL SUSPENSIONS",           "ACTION COUNTS",
  "iss_students",    "^B-",                        "IN SCHOOL SUSPENSIONS",           "STUDENT COUNTS",
  "oss_actions",     "^B-",                        "OUT OF SCHOOL SUSPENSIONS",       "ACTION COUNTS",
  "oss_students",    "^B-",                        "OUT OF SCHOOL SUSPENSIONS",       "STUDENT COUNTS",
  "daep_disc",       "^B-",                        "DISCRETIONARY DAEP PLACEMENTS",   "ACTION COUNTS",
  # By race (sections C = ISS, D = OSS, E = discretionary DAEP)
  "iss_black",       "^C-",                        "BLACK OR AFRICAN AMERICAN",       "ACTION COUNTS",
  "iss_white",       "^C-",                        "WHITE",                           "ACTION COUNTS",
  "oss_black",       "^D-",                        "BLACK OR AFRICAN AMERICAN",       "ACTION COUNTS",
  "oss_white",       "^D-",                        "WHITE",                           "ACTION COUNTS",
  "daep_disc_black", "^E-DISCRETIONARY DAEP",      "BLACK OR AFRICAN AMERICAN",       "ACTION COUNTS",
  "daep_disc_white", "^E-DISCRETIONARY DAEP",      "WHITE",                           "ACTION COUNTS"
)

# ---- Convert TEA count strings to numbers -----------------------------------
# TEA masks small cells for student privacy (FERPA) with entries such as
# "<10", "<20" or "<1,050". Any entry containing "<", ">" or "*", any other
# non-numeric entry, and any negative code becomes NA.
# A masked cell is "unknown", not zero: it must show as grey "No data".
tea_to_number <- function(x) {
  v <- stringr::str_trim(as.character(x))
  v[stringr::str_detect(v, "[<>*]")] <- NA_character_
  v <- stringr::str_remove_all(v, ",")
  num <- suppressWarnings(as.numeric(v))
  num[!is.na(num) & num < 0] <- NA_real_
  num
}

# ---- Read ONE TEA Annual District Summary CSV -------------------------------
# Columns (TEA 2018-19 file): AGGREGATION_LEVEL, REGION, DISTNAME, DISTRICT,
# CHARTER_STATUS, SECTION, HEADING_NAME, INDICATOR, VALUE.
read_tea_district_file <- function(path) {
  if (!file.exists(path)) stop("File not found: ", path, call. = FALSE)

  year_label <- stringr::str_extract(basename(path), "20[0-9]{2}-[0-9]{2}")
  if (is.na(year_label)) {
    stop("Cannot read the school year from the file name '", basename(path),
         "'. Name files like tea_discipline_district_2023-24.csv", call. = FALSE)
  }

  # Some exports start with title lines; locate the real header row.
  first_lines <- readLines(path, n = 60, warn = FALSE, encoding = "latin1")
  header_row <- which(stringr::str_detect(toupper(first_lines), "HEADING"))[1]
  if (is.na(header_row)) {
    stop("No header row containing 'HEADING' in ", basename(path),
         ". First lines of the file:\n", paste(utils::head(first_lines, 5), collapse = "\n"),
         call. = FALSE)
  }

  # Footer lines at the end of TEA files have 1 column; they are read as NA
  # rows (this is the harmless "parsing issues" warning) and dropped below.
  raw <- suppressWarnings(
    readr::read_csv(path, skip = header_row - 1,
                    col_types = readr::cols(.default = readr::col_character()),
                    locale = readr::locale(encoding = "latin1"),
                    show_col_types = FALSE, progress = FALSE)
  ) |>
    janitor::clean_names()

  required <- c("district", "section", "heading_name", "indicator", "value")
  missing_cols <- setdiff(required, names(raw))
  if (length(missing_cols) > 0) {
    stop("Columns missing from ", basename(path), ": ", paste(missing_cols, collapse = ", "),
         ". Columns found: ", paste(names(raw), collapse = ", "), call. = FALSE)
  }
  name_col <- intersect(c("distname", "district_name"), names(raw))[1]

  tibble::tibble(
    year = year_label,
    # Fix leading zeros / apostrophes so every CDN is a 6-character string
    cdn = stringr::str_pad(stringr::str_remove_all(raw$district, "[^0-9]"), 6, pad = "0"),
    district_name  = if (is.na(name_col)) NA_character_ else stringr::str_squish(raw[[name_col]]),
    charter_status = if ("charter_status" %in% names(raw)) stringr::str_squish(raw$charter_status) else NA_character_,
    section      = stringr::str_squish(toupper(raw$section)),
    heading_name = stringr::str_squish(toupper(raw$heading_name)),
    indicator    = stringr::str_squish(toupper(raw$indicator)),
    value        = tea_to_number(raw$value)
  ) |>
    dplyr::filter(!is.na(section), !is.na(cdn), nchar(cdn) == 6, cdn != "000000")
}

# ---- Combine all years and compute normalized measures ----------------------
build_discipline_table <- function(paths) {
  long <- purrr::map(paths, read_tea_district_file) |> purrr::list_rbind()

  # Attach a variable name to each TEA row we need
  matched <- purrr::pmap(tea_items, function(var, section_pattern, heading, indicator) {
    long |>
      dplyr::filter(stringr::str_detect(.data$section, section_pattern),
                    .data$heading_name == heading,
                    .data$indicator == indicator) |>
      dplyr::transmute(year, cdn, var = var, value)
  }) |> purrr::list_rbind()

  # Every item must exist in every year; otherwise TEA changed a label.
  found <- dplyr::distinct(matched, year, var)
  expected <- tidyr::expand_grid(year = unique(long$year), var = tea_items$var)
  absent <- dplyr::anti_join(expected, found, by = c("year", "var"))
  if (nrow(absent) > 0) {
    detail <- absent |> dplyr::group_by(year) |>
      dplyr::summarise(vars = paste(var, collapse = ", "), .groups = "drop")
    stop("These TEA rows were not found (label changed?):\n",
         paste0("  ", detail$year, ": ", detail$vars, collapse = "\n"), call. = FALSE)
  }

  # One row per district-year that appears anywhere in the TEA file
  districts_tbl <- long |>
    dplyr::distinct(year, cdn, district_name, charter_status) |>
    dplyr::distinct(year, cdn, .keep_all = TRUE)

  # TEA prints a row only when a category has students/actions, so a missing
  # row is a zero. A printed but masked value ("<10") stays NA.
  wide <- matched |>
    tidyr::pivot_wider(names_from = var, values_from = value,
                       values_fn = dplyr::first, values_fill = 0)
  wide <- districts_tbl |> dplyr::inner_join(wide, by = c("year", "cdn"))

  rate <- function(num, den, per) dplyr::if_else(!is.na(den) & den > 0, per * num / den, NA_real_)

  wide |>
    dplyr::mutate(
      # Count (total) -> proportional symbols (Part B.5)
      disc_n          = iss_actions + oss_actions + daep_disc,
      # Rates and shares -> choropleths (Part B.3, B.4, Part C)
      disc_rate       = rate(disc_n, enrolled, 100),
      iss_pct         = rate(iss_students, enrolled, 100),
      oss_pct         = rate(oss_students, enrolled, 100),
      daep_disc_rate  = rate(daep_disc, enrolled, 1000),
      black_disc_rate = rate(iss_black + oss_black + daep_disc_black, enr_black, 100),
      white_disc_rate = rate(iss_white + oss_white + daep_disc_white, enr_white, 100),
      # Risk ratio: Black rate / White rate (1 = parity); undefined if White rate is 0
      rr_bw           = dplyr::if_else(!is.na(white_disc_rate) & white_disc_rate > 0,
                                       black_disc_rate / white_disc_rate, NA_real_),
      rr_denom        = pmin(enr_black, enr_white)
    ) |>
    dplyr::select(year, cdn, district_name, charter_status, enrolled, enr_black, enr_white,
                  disc_n, disc_rate, iss_pct, oss_pct, daep_disc_rate,
                  black_disc_rate, white_disc_rate, rr_bw, rr_denom) |>
    dplyr::arrange(year, cdn)
}

# ---- CDN -> NCES LEAID crosswalk (NCES CCD directory) ------------------------
# Endpoint and fields (leaid, state_leaid, lea_name) follow the Urban Institute
# Education Data API documentation. state_leaid looks like "TX-057905"; its
# last six digits are the TEA CDN.
get_ccd_crosswalk <- function(ccd_year = 2022) {
  url <- sprintf(
    "https://educationdata.urban.org/api/v1/school-districts/ccd/directory/%d/?fips=48",
    as.integer(ccd_year))
  pages <- list()
  while (!is.null(url) && length(url) == 1 && !is.na(url) && nzchar(url)) {
    body <- jsonlite::fromJSON(url)
    res <- tibble::as_tibble(body$results)
    if (!all(c("leaid", "state_leaid") %in% names(res))) {
      stop("The CCD API response lacks leaid/state_leaid. Fields returned: ",
           paste(names(res), collapse = ", "), call. = FALSE)
    }
    pages[[length(pages) + 1]] <- dplyr::select(res, dplyr::any_of(c("leaid", "state_leaid", "lea_name")))
    url <- body[["next"]]
    Sys.sleep(1)  # be polite to the public API
  }
  purrr::list_rbind(pages) |>
    dplyr::transmute(
      geoid = sprintf("%07d", as.integer(leaid)),
      cdn   = stringr::str_sub(stringr::str_remove_all(as.character(state_leaid), "[^0-9]"), -6),
      lea_name = if ("lea_name" %in% names(pages[[1]])) as.character(lea_name) else NA_character_
    ) |>
    dplyr::filter(nchar(cdn) == 6) |>
    dplyr::distinct(cdn, .keep_all = TRUE) |>
    dplyr::distinct(geoid, .keep_all = TRUE)
}

# ---- Census school-district boundaries via tigris ---------------------------
# Unified districts are the default; Texas may also have elementary/secondary
# districts, so each type is requested and missing types are skipped.
get_tx_boundaries <- function(tiger_year = 2023) {
  types <- c("unified", "elementary", "secondary")
  parts <- purrr::map(types, function(t) {
    tryCatch({
      bd <- tigris::school_districts(state = "TX", type = t, cb = TRUE,
                                     year = tiger_year, progress_bar = FALSE)
      bd <- bd[, c("GEOID", "NAME")]
      names(bd)[names(bd) == "GEOID"] <- "geoid"
      names(bd)[names(bd) == "NAME"]  <- "district_boundary_name"
      bd$sd_type <- t
      sf::st_transform(bd, 4326)
    }, error = function(e) {
      message("No ", t, " school districts returned for Texas (", conditionMessage(e), ")")
      NULL
    })
  })
  parts <- purrr::compact(parts)
  if (length(parts) == 0) stop("tigris returned no Texas school-district boundaries.", call. = FALSE)

  do.call(rbind, parts) |>
    # Census placeholder polygons are not real districts
    dplyr::filter(!stringr::str_detect(district_boundary_name, "Not Defined")) |>
    sf::st_make_valid() |>
    dplyr::distinct(geoid, .keep_all = TRUE)
}
