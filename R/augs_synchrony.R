#' Calculate Augspurgers index of synchrony
#'
#' Calculate Augspurgers Index of Synchrony from a dataframe.
#'
#' @param dataset a data frame containing values to perform calculations on
#' @param year_samp column holding information on year, required even if all events occur in the same year due to leap years
#' @param frst_day column containing the INITIATION DATE of a phenological event
#' @param lst_day column containing the FINAL DATE of a phenological event
#' @param ... in this case grouping variables (within year!)
#' @return a dataframe with attached results, see example
#' @examples
#' library(AugspurgerIndex)
#' data('flowering_data')
#' head(flowering_data)
#' synchrony <- augs_synchrony(dataset = flowering_data,
#'   frst_day = flower_start, lst_day = flower_end,
#'   year_samp = year, species )
#'
#' head(synchrony)
#' @export
augs_synchrony <- function(dataset, year_samp, frst_day, lst_day, ...){

  frst_day <- rlang::enquo(frst_day)
  lst_day <- rlang::enquo(lst_day)
  year_samp <- rlang::enquo(year_samp)
  grp_vars <- rlang::enquos(...)

  dataset <- dataset |>
    dplyr::mutate(dplyr::across(c(!!frst_day, !!lst_day), function(x) as.integer(x)))

  results <- dataset |>
    dplyr::group_by(!!year_samp, !!!(grp_vars)) |>

    # TERM A FOR THE INDIVIDUAL $X_{i}$

    # term one population (\frac{1}{n-1})
    dplyr::mutate(at1 = 1/(dplyr::n() -1)) |>
    dplyr::mutate(dplyr::across(c(!!frst_day, !!lst_day),
                  function(x)
                    lubridate::as_date(x, origin =
                                         paste0(!!year_samp - 1, "-12-31")))
    ) |>
    dplyr::mutate(interval_obs = lubridate::interval(lubridate::ymd(!!frst_day),
                                                     lubridate::ymd(!!lst_day))) |>

    # term two, (\frac{1}{f_{i}}) duration of event for individual.
    # note duration returns seconds, but these data are at resolution of day.
    dplyr::mutate(at2 = 1/
             (as.numeric(
               lubridate::as.duration(!!lst_day - !!frst_day)
             )
             /86400
             )
    ) |>

    # term 3: all days individual i is flowering with other individuals
    # \sum_{j = i}^{n} e_{j != i}
    dplyr::mutate(at3 = purrr::map_dbl(.data$interval_obs, # @ shs on SO
                         \(x) x |>
                           lubridate::intersect(.data$interval_obs) |>
                           lubridate::int_length() |>
                           sum(na.rm = T) - lubridate::int_length(x)
    ) / 86400) |>

    # the index of synchrony for individual i
    dplyr::rowwise() |>
    dplyr::mutate(augs.indx.indiv. = .data$at1 * .data$at2 * .data$at3) |>
    dplyr::group_by(!!year_samp,  !!!(grp_vars)) |>

    ## TERM B FOR THE POPULATION
    dplyr::mutate(bt1 = 1/dplyr::n()) |>  # $\frac{1}{n}$ 1/sample size
    dplyr::mutate(bt2 = sum(.data$augs.indx.indiv.)) |>  # \sum_{j = 1}^{n}X_{i}
    dplyr::mutate(augs.index.pop = .data$bt1 * .data$bt2) |>

    # clean return data
    dplyr::select(-.data$at1, -.data$at2, -.data$at3, -.data$bt1,
                  -.data$bt2, -.data$interval_obs)

  return(results)

}
