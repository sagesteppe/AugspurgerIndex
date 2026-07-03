<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CRAN
checks](https://badges.cranchecks.info/summary/badger.svg)](https://cran.r-project.org/web/checks/check_results_badger.html)
[![R build
status](https://github.com/sagesteppe/AugspurgerIndex/workflows/R-CMD-check/badge.svg)](https://github.com/sagesteppe/AugspurgerIndex/actions)
[![CodeFactor](https://www.codefactor.io/repository/github/sagesteppe/AugspurgerIndex/badge)](https://www.codefactor.io/repository/github/sagesteppe/AugspurgerIndex)
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://img.shields.io/badge/doi-10.5281/zenodo.21173019-orange.svg)](https://doi.org/10.5281/zenodo.21173019)
[![](https://codecov.io/gh/sagesteppe/AugspurgerIndex/branch/main/graph/badge.svg)](https://app.codecov.io/gh/sagesteppe/AugspurgerIndex)

# AugspurgerIndex

**AugspurgerIndex is an R package with a single function,
`augs_synchrony()`, that calculates Augspurger’s Index of Synchrony**
(Augspurger 1983), a quantitative measure of how much the flowering (or
other phenological) periods of individuals in a population overlap in
time. It implements the method exactly as described in Primack (1980)
and Augspurger (1983), operates on plain rectangular (“tidy”) data
frames, and returns both an individual-level synchrony score and a
population-level synchrony score.

## What is Augspurger’s Index of Synchrony?

Augspurger’s Index of Synchrony is a phenology metric used in ecology
and botany to quantify how well the timing of a life-history event -
most often flowering, but applicable to any event with a duration is
synchronized across individuals in a population. It is calculated in two
parts:

  - **Part A — individual synchrony ($X_i$):** for each individual
    *i*, the proportion of its flowering duration that overlaps with
    every other individual *j* in the population, averaged across all
    *j*.
  - **Part B — population synchrony ($Z$):** the mean of all
    individual synchrony values ($X_i$) across the population.

Values range from 0 (no individual overlaps in time with any other
individual) to 1 (perfect synchrony, i.e. all individuals flower on
exactly the same days).

This from Augspurger 1983:

> ## APPENDIX 1. Methods of Calculating Synchrony (modified from Primack 1980).
> 
> **A.** Synchrony of a given individual with its conspecifics:
> $X_{i}$, the index of synchrony for individual i, is defined
> 
> $$
> X_{i} = (\frac{1}{n-1})(\frac{1}{f_{i}})\sum_{j = i}^{n} e_{j != i}
> $$
> 
> where,
> 
> $e_{j}$ = number of days both individuals *i* and *j* are flowering
> synchronously, *j* \!= *i*  
> $f_{i}$ = number of days individual *i* is flowering  
> $n$ = number of individuals in population
> 
> When X = 1.0, perfect synchrony occurs, i.e., all flowering days of
> individual *i* overlap with all flowering days of each other
> individual, *j \# i*, in the \> population.  
> When X = 0.0, no synchrony occurs, i.e., no overlap occurs among any
> of the flowering days of individual *i* and any other individual, *j
> =\# i*, in the \> population.
> 
> **B.** Synchrony of the population: $Z$, the index of population
> synchrony, is defined as:
> 
> $$
> Z= \frac{1}{n}\sum_{j = 1}^{n}X_{i}
> $$
> 
> where $X_{i}$ is synchrony of individual *i* with its conspecifics
> from part A (above)

## Why use this package?

Earlier CRAN packages which implemented Augspurger’s Index of Synchrony
have since been removed for failing builds, or only work on
non-rectangular data. `AugspurgerIndex` is a minimal, dependency-light
re-implementation that:

  - accepts standard rectangular (tidy) data frames,
  - correctly handles multi-year data sets, including leap years,
  - supports grouping by any number of variables (e.g. species, site,
    plot) via `...`,
  - returns results in the same data frame passed in, so they can be
    piped directly into further analysis or plotting.

## Installation

The package can be installed from either GitHub, using the remotes
package, or CRAN. For most users I recommend installing from CRAN.

    install.packages('remotes', dependencies = T)
    remotes::install_github('sagesteppe/AugspurgerIndex')

## Usage

`augs_synchrony()` takes a data frame containing, at minimum, a year
column and start/end date columns for the phenological event of
interest. Any additional columns passed via `...` are used as grouping
variables (e.g. species or site), so that synchrony is calculated
separately within each group and year.

``` r
library(AugspurgerIndex)
set.seed(23)

data('flowering_data')
recs = sample(1:nrow(flowering_data),5)
flowering_data[recs,]
```

    ##      species year flower_start flower_end median_flowers lower_sd upper_sd
    ## 29  tauschia 2012          250        252            251      250      252
    ## 28  tauschia 2012          240        260            251      247      256
    ## 8   lomatium 2014          190        200            193      191      196
    ## 17 podistera 2011          180        190            185      183      187
    ## 23 podistera 2011          191        200            195      192      196

``` r
synchrony <- augs_synchrony(
  dataset = flowering_data,
  frst_day = flower_start, lst_day = flower_end,
  year_samp = year, species
)

cols = c('species','flower_start', 'flower_end',
 'augs.indx.indiv.', 'augs.index.pop')
synchrony[recs,cols]
```

    ## # A tibble: 5 × 5
    ## # Groups:   species [3]
    ##   species   flower_start flower_end augs.indx.indiv. augs.index.pop
    ##   <chr>     <date>       <date>                <dbl>          <dbl>
    ## 1 tauschia  2012-09-06   2012-09-08            0.5            0.223
    ## 2 tauschia  2012-08-27   2012-09-16            0.421          0.223
    ## 3 lomatium  2014-07-09   2014-07-19            1              1    
    ## 4 podistera 2011-06-29   2011-07-09            0.636          0.630
    ## 5 podistera 2011-07-10   2011-07-19            0.636          0.630

`augs.indx.indiv.` is the individual-level synchrony score ($X_i$) and
`augs.index.pop` is the population-level synchrony score ($Z$) for
that group and year.

## Citation

    citation('AugspurgerIndex')

Please cite AugspurgerIndex in publications using:

Reed C. Benkendorf (2023). AugspurgerIndex,
<https://github.com/sagesteppe/AugspurgerIndex>

A BibTeX entry for LaTeX users is

@Misc{,  
title = {AugspurgerIndex},  
author = {Reed Clark Benkendorf},  
year = {2023},  
url = {<https://github.com/sagesteppe/AugspurgerIndex>},  
}

Machine-readable metadata for this package (author, license,
dependencies, and citations as JSON-LD/schema.org) is available in
[`codemeta.json`](./codemeta.json).

# Interpreting synchrony values: some notes

![Four dot-and-whisker panels, one per fictitious species (lomatium,
musineon, podistera, tauschia), plotting each individual’s flowering
period by day of year: dotted whiskers show the full flowering range
used in the synchrony calculation, solid arrows show the mean plus or
minus one standard deviation, and dots mark the median (peak) flowering
date.](./man/figures/AugsPanel.png) ![Four dot plots, one per fictitious
species, plotting each individual’s synchrony score from 0 to 1 against
a dashed line marking that species’ population-level synchrony: lomatium
individuals are fully synchronous (all scores near 1), musineon
individuals are fully asynchronous (all scores near 0), podistera
individuals cluster uniformly around 0.65, and tauschia shows the more
realistic, scattered spread of individual synchrony values discussed
below.](./man/figures/IndexPanel.png)

The fourth pane shows some un-intuitive aspects of the measure of
individual synchrony. Individuals 7, 8, 9, 11, and 12, which have no to
little overlap with other individuals have very low values of synchrony.
Individuals 5, 6, and 10, despite having very short periods of
flowering, overlap well with the lowermost individuals, and have the
highest values of synchrony. Perhaps counterintuitively, individuals 1-3
which have long periods of flowering, and which overlap with fewer
individuals over these time periods are the most asynchronous. In a
casual sense metrics of synchrony are simply measuring the overlap in
phenophase, without respect to duration.

## References

Augspurger, Carol K. *Phenology, Flowering Synchrony, and Fruit Set of
Six Neotropical Shrubs.* Biotropica, vol. 15, no. 4, 1983, pp. 257–267.
JSTOR, <https://doi.org/10.2307/2387650>. Accessed 19 Mar. 2022.

Augspurger, Carol K. *Reproductive Synchrony of a Tropical Shrub:
Experimental Studies on Effects of Pollinators and Seed Predators in
Hybanthus Prunifolius (Violaceae).* Ecology, vol. 62, no. 3, 1981,
pp. 775–788. JSTOR, <https://doi.org/10.2307/1937745>. Accessed 19
Mar. 2022.

Primack, Richard B. *Variation in the Phenology of Natural Populations
of Montane Shrubs in New Zealand.* Journal of Ecology, vol. 68, no. 3,
1980, pp. 849–862. JSTOR, <https://doi.org/10.2307/2259460>. Accessed 19
Mar. 2022.

## 

*This function very warmly, and humbly, acknowledges Carol Augspurger,
or ‘Dr. A’ as many alumni of UIUC have the privilege to know her. One of
the only ecologists, to be a great natural historian, accomplished
academic, excellent instructor, devout environmentalist, and un-paralled
mentor.*
