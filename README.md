
# imputomics <img src='man/figures/logo.png' align="right" height="150"/>

*imputomics* is an R package and a shiny web server designed to simulate
and impute missing values. It offers 42 algorithms for imputing missing
values, especially in different types of ‘-omics’ data such as genomics,
transcriptomics, proteomics, and metabolomics. imputomics provides a
user-friendly interface that allows users to simulate missing values
based on different distributions and impute missing values using
state-of-the-art methods.

## Key Features:

1.  Imputation methods: imputomics offers the biggest collection of
    imputation methods for different types of omics data, including
    k-nearest neighbors (KNN), random forests, expectation-maximization
    (EM) algorithm, and principal components analysis (PCA) and many
    others.

2.  Performance evaluation: imputomics facilitates evaluating the
    performance of imputation methods. Users can evaluate imputation
    accuracy and compare different methods using metrics such as root
    mean squared error (RMSE), mean absolute error (MAE), and
    coefficient of determination (R-squared).

3.  Simulation of missing values: imputomics provides a variety of
    options for simulating missing values, including missing completely
    at random (MCAR), missing at random (MAR), and missing not at random
    (MNAR) mechanisms. Users can specify the percentage of missing
    values and the distribution from which the missing values are
    generated.

# Getting started

This repository contains the data and code necessary to reproduce the
results from the paper *imputomics: comprehensive missing data
imputation for metabolomics data*. It uses
[renv](https://CRAN.R-project.org/package=renv) package to assure the
reproducibility. As *imputomics* implements lots of missing value
imputations methods from other R packages.

## Webserver

The *imputomics* can be accessed through our [web
server](https://biogenies.info/imputomics-ws/).

## Installation

*imputomics* is available on
[GitHub](https://github.com/BioGenies/imputomics)

To install *imputomics* you need to have *R* version \>= 4.2.0.

``` r
devtools::install_github("BioGenies/imputomics")
```

Sometimes, not all packages can be installed on the first try. In this
case, consider re-running the *install_github* function.

### Docker

To enhance the reproducibility of *imputomics*, we share it also as a
[rocker-based](https://github.com/rocker-org) container. The docker
manifest is available in the *imputomics* repository:
<https://github.com/BioGenies/imputomics/blob/main/Dockerfile_imputomics>.

## Reproducibility

To reproduce our environment you need to git clone our repo and activate
renv.

``` bash
git clone https://github.com/BioGenies/imputomics.git
```

``` r
renv::activate()
renv::restore()
```

### Troubleshooting

Q: I am receiving the following error message: “Error: HTTP error 403.
API rate limit exceeded for \[my IP\]”. A: Due to its comprehensiveness,
*imputomics* downloads many packages from GitHub, which may lead to
exceeding the limit of GitHub API queries. Please consider setting the
GitHub API token with usethis::create_github_token().

## Run imputomics

To run *imputomics* type the following command into an R console.

``` r
imputomics::imputomics_gui()
```

<!-- # How to cite -->

#### How to cite?

Jarosław Chilimoniuk, Krystyna Grzesiak, Jakub Kała, Dominik Nowakowski,
Adam Krętowski, Rafał Kolenda, Michał Ciborowski, Michał Burdukiewicz
(2023). imputomics: web server and R package for missing values
imputation in metabolomics data, *Bioinformatics*,
[10.1093/bioinformatics/btae098](https://doi.org/10.1093/bioinformatics/btae098).

#### Contact

If you have any questions, suggestions or comments, contact [Michal
Burdukiewicz](mailto:michalburdukiewicz@gmail.com).

#### Funding and acknowledgements

We want to thank the Clinical Research Centre (Medical University of
Białystok) members for fruitful discussions. K.G. wants to acknowledge
grant no. 2021/43/O/ST6/02805 (National Science Centre). M.C.
acknowledges grant no. B.SUB.23.533 (Medical University of Białystok).
The study was supported by the Ministry of Education and Science funds
within the project ‘Excellence Initiative - Research University’. We
also acknowledge the Center for Artificial Intelligence at the Medical
University of Białystok (funded by the Ministry of Health of the
Republic of Poland).

<img src='man/figures/funding.png' style='height: 90px'>


## Local imputation implementations

`impute_mnmf()` now uses a local nonnegative matrix factorization solver;
`NMF` and `pkgmaker` are no longer required. It follows the
[Xu et al. mNMF workflow](https://doi.org/10.3390/molecules26195787), using
multiplicative KL-divergence updates. Use `set.seed()` for reproducibility.
Results can differ numerically from the former NMF package implementation.

`impute_imputation_knn()` uses a bundled adaptation of **Jeffrey Wong's code**
from [imputation 2.0.3](https://github.com/jeffwong/imputation), revision
`c1cc5e4db150dc5fe4fa069be0670284143a105f`, distributed under GPL.
It no longer downloads that package or its TimeProjection dependency.
Please cite Wong, J. (2013), *imputation: Fill missing values in a data matrix*,
and [Troyanskaya et al. (2001)](https://doi.org/10.1093/bioinformatics/17.6.520).
Source links and adaptation details are in [inst/NOTICE](inst/NOTICE).


## Dependency environment

The updated environment targets R 4.6 with Bioconductor 3.23 and renv 1.3.1.
Run `renv::restore()` from the project to reproduce the versions in `renv.lock`.
The library is kept under `renv/library`, separated by R version and platform.
To refresh repository dependencies, run `Rscript --vanilla update-dependencies.R`
from the repository root. Windows source packages require a compatible Rtools.

MAI now comes from Bioconductor. PEMM 1.0 and missCompare 1.0.3 use their
last available CRAN archive releases. DreamAI and MetabImpute are pinned to the
upstream revisions fetched during this update; their pins in DESCRIPTION and
the update script must be changed together when updating those sources.
