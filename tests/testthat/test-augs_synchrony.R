test_that("output preserves row count and adds expected columns", {
  df <- data.frame(
    species = "a", year = 2020,
    start = c(1, 5, 9), end = c(10, 15, 20)
  )
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_equal(nrow(res), nrow(df))
  expect_true(all(c("augs.indx.indiv.", "augs.index.pop") %in% colnames(res)))
})

test_that("identical intervals yield perfect synchrony (index of 1)", {
  df <- data.frame(
    species = "a", year = 2020,
    start = c(100, 100, 100), end = c(110, 110, 110)
  )
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_equal(res$augs.indx.indiv., rep(1, 3))
  expect_equal(res$augs.index.pop, rep(1, 3))
})

test_that("non-overlapping intervals yield zero synchrony", {
  df <- data.frame(
    species = "a", year = 2020,
    start = c(1, 50, 100), end = c(10, 60, 110)
  )
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_equal(res$augs.indx.indiv., rep(0, 3))
  expect_equal(res$augs.index.pop, rep(0, 3))
})

test_that("partial overlap matches hand-calculated values", {
  # individual 1: day 1-10 (9 day duration), individual 2: day 5-15 (10 day duration)
  # overlap is days 5-10 (5 days) for both
  df <- data.frame(
    species = "a", year = 2020,
    start = c(1, 5), end = c(10, 15)
  )
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_equal(res$augs.indx.indiv., c(5 / 9, 0.5))
  expect_equal(res$augs.index.pop, rep(0.5 * (5 / 9 + 0.5), 2))
})

test_that("groups (year/grouping vars) are calculated independently", {
  df <- data.frame(
    species = c("a", "a", "b", "b"),
    year = 2020,
    start = c(1, 1, 1, 50),
    end = c(10, 10, 10, 60)
  )
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_equal(res$augs.indx.indiv.[res$species == "a"], c(1, 1))
  expect_equal(res$augs.indx.indiv.[res$species == "b"], c(0, 0))
})

test_that("a single individual in a group returns NaN rather than erroring", {
  df <- data.frame(species = "a", year = 2020, start = 100, end = 110)
  res <- augs_synchrony(df, year_samp = year, frst_day = start, lst_day = end, species)

  expect_true(is.nan(res$augs.indx.indiv.))
  expect_true(is.nan(res$augs.index.pop))
})

test_that("works on the bundled flowering_data example", {
  res <- augs_synchrony(
    dataset = flowering_data, frst_day = flower_start, lst_day = flower_end,
    year_samp = year, species
  )

  expect_equal(nrow(res), nrow(flowering_data))
  # musineon individuals in this dataset never overlap in flowering window
  expect_equal(unique(res$augs.index.pop[res$species == "musineon"]), 0)
  # lomatium individuals share an identical flowering window
  expect_equal(unique(res$augs.index.pop[res$species == "lomatium"]), 1)
})
