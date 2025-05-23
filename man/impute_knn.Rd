% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/imputing.R
\name{impute_knn}
\alias{impute_knn}
\title{\strong{kNN} imputation.}
\usage{
impute_knn(missdf, ...)
}
\arguments{
\item{missdf}{a data frame with missing values to be imputed
containing features in columns and samples in rows.}

\item{...}{other parameters of \code{\link[impute:impute.knn]{impute::impute.knn()}} besides \code{data}.}
}
\value{
A \code{data.frame} with imputed values by \code{\link[impute:impute.knn]{impute::impute.knn()}}.
}
\description{
K Nearest Neighbors.
}
\details{
A function to replace \code{NA} in the data frame by \code{\link[impute:impute.knn]{impute::impute.knn()}}.
}
\section{Silent defaults}{

\code{impute.knn} sets its \code{rng.seed} by default to 362436069. To avoid it,
\code{imputomics} by default uses \code{sample(1L:1e9, 1)}.
}

\examples{
data(sim_miss)
impute_knn(sim_miss)

}
\references{
\insertRef{hastie_impute_2023}{imputomics}
}
\seealso{
\code{\link[impute:impute.knn]{impute::impute.knn()}}
}
