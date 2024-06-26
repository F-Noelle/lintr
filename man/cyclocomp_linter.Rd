% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cyclocomp_linter.R
\name{cyclocomp_linter}
\alias{cyclocomp_linter}
\title{Cyclomatic complexity linter}
\usage{
cyclocomp_linter(complexity_limit = 15L)
}
\arguments{
\item{complexity_limit}{Maximum cyclomatic complexity, default \code{15}. Expressions more complex
than this are linted.}
}
\description{
Check for overly complicated expressions. See \code{cyclocomp()} function from \code{{cyclocomp}}.
}
\examples{
\dontshow{if (requireNamespace("cyclocomp", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# will produce lints
lint(
  text = "if (TRUE) 1 else 2",
  linters = cyclocomp_linter(complexity_limit = 1L)
)

# okay
lint(
  text = "if (TRUE) 1 else 2",
  linters = cyclocomp_linter(complexity_limit = 2L)
)
\dontshow{\}) # examplesIf}
}
\seealso{
\link{linters} for a complete list of linters available in lintr.
}
\section{Tags}{
\link[=best_practices_linters]{best_practices}, \link[=configurable_linters]{configurable}, \link[=readability_linters]{readability}, \link[=style_linters]{style}
}
