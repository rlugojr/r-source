% File src/library/stats/man/reshape.Rd
% Part of the R package, http://www.R-project.org
% Copyright 1995-2012 R Core Team
% Distributed under GPL 2 or later

\name{reshape}
\alias{reshape}
\title{Reshape Grouped Data}
\description{
  This function reshapes a data frame between \sQuote{wide} format with
  repeated measurements in separate columns of the same record and
  \sQuote{long} format with the repeated measurements in separate
  records.
}
\usage{
reshape(data, varying = NULL, v.names = NULL, timevar = "time",
        idvar = "id", ids = 1:NROW(data),
        times = seq_along(varying[[1]]),
        drop = NULL, direction, new.row.names = NULL,
        sep = ".",
        split = if (sep == "") {
            list(regexp = "[A-Za-z][0-9]", include = TRUE)
        } else {
            list(regexp = sep, include = FALSE, fixed = TRUE)}
        )

}
\arguments{
  \item{data}{a data frame}
  \item{varying}{names of sets of variables in the wide format that
    correspond to single variables in long format
    (\sQuote{time-varying}).  This is canonically a list of vectors of
    variable names, but it can optionally be a matrix of names, or a
    single vector of names.  In each case, the names can be replaced by
    indices which are interpreted as referring to \code{names(data)}.
    See \sQuote{Details} for more details and options.}
  \item{v.names}{names of variables in the long format that correspond
    to multiple variables in the wide format.  See \sQuote{Details}.}
  \item{timevar}{the variable in long format that differentiates multiple
    records from the same group or individual.  If more than one record
    matches, the first will be taken (with a warning). }
  \item{idvar}{Names of one or more variables in long format that
    identify multiple records from the same group/individual.  These
    variables may also be present in wide format.}
  \item{ids}{the values to use for a newly created \code{idvar}
    variable in long format.}
  \item{times}{the values to use for a newly created \code{timevar}
    variable in long format.  See \sQuote{Details}.}
  \item{drop}{a vector of names of variables to drop before reshaping.}
  \item{direction}{character string, partially matched to either
    \code{"wide"} to reshape to wide format, or \code{"long"} to reshape
    to long format.}
  \item{new.row.names}{character or \code{NULL}: a non-null value will be
    used for the row names of the result.}
  \item{sep}{A character vector of length 1, indicating a separating
    character in the variable names in the wide format.  This is used for
    guessing \code{v.names} and \code{times} arguments based on the
    names in \code{varying}.  If \code{sep == ""}, the split is just before
    the first numeral that follows an alphabetic character.  This is
    also used to create variable names when reshaping to wide format.}
  \item{split}{A list with three components, \code{regexp},
    \code{include}, and (optionally) \code{fixed}.  This allows an
    extended interface to variable name splitting.  See \sQuote{Details}.}
}
\details{
  The arguments to this function are described in terms of longitudinal
  data, as that is the application motivating the functions.  A
  \sQuote{wide} longitudinal dataset will have one record for each
  individual with some time-constant variables that occupy single
  columns and some time-varying variables that occupy a column for each
  time point.  In \sQuote{long} format there will be multiple records
  for each individual, with some variables being constant across these
  records and others varying across the records.  A \sQuote{long} format
  dataset also needs a \sQuote{time} variable identifying which time
  point each record comes from and an \sQuote{id} variable showing which
  records refer to the same person.

  If the data frame resulted from a previous \code{reshape} then the
  operation can be reversed simply by \code{reshape(a)}.  The
  \code{direction} argument is optional and the other arguments are
  stored as attributes on the data frame.

  If \code{direction = "wide"} and no \code{varying} or \code{v.names}
  arguments are supplied it is assumed that all variables except
  \code{idvar} and \code{timevar} are time-varying.  They are all
  expanded into multiple variables in wide format.

  If \code{direction = "long"} the \code{varying} argument can be a vector
  of column names (or a corresponding index).  The function will attempt
  to guess the \code{v.names} and \code{times} from these names.  The
  default is variable names like \code{x.1}, \code{x.2}, where
  \code{sep = "."} specifies to split at the dot and drop it from the
  name.  To have alphabetic followed by numeric times use \code{sep = ""}.

  Variable name splitting as described above is only attempted in the
  case where \code{varying} is an atomic vector, if it is a list or a
  matrix, \code{v.names} and \code{times} will generally need to be
  specified, although they will default to, respectively, the first
  variable name in each set, and sequential times.

  Also, guessing is not attempted if \code{v.names} is given
  explicitly.  Notice that the order of variables in \code{varying} is
  like \code{x.1},\code{y.1},\code{x.2},\code{y.2}.

  The \code{split} argument should not usually be necessary.  The
  \code{split$regexp} component is passed to either
  \code{\link{strsplit}} or \code{\link{regexpr}}, where the latter is
  used if \code{split$include} is \code{TRUE}, in which case the
  splitting occurs after the first character of the matched string.  In
  the \code{\link{strsplit}} case, the separator is not included in the
  result, and it is possible to specify fixed-string matching using
  \code{split$fixed}.
}
\value{
  The reshaped data frame with added attributes to simplify reshaping
  back to the original form.
}
\seealso{\code{\link{stack}}, \code{\link{aperm}};
  \code{\link{relist}} for reshaping the result of \code{\link{unlist}}.
}
\examples{
summary(Indometh)
wide <- reshape(Indometh, v.names = "conc", idvar = "Subject",
                timevar = "time", direction = "wide")
wide

reshape(wide, direction = "long")
reshape(wide, idvar = "Subject", varying = list(2:12),
        v.names = "conc", direction = "long")

## times need not be numeric
df <- data.frame(id = rep(1:4, rep(2,4)),
                 visit = I(rep(c("Before","After"), 4)),
                 x = rnorm(4), y = runif(4))
df
reshape(df, timevar = "visit", idvar = "id", direction = "wide")
## warns that y is really varying
reshape(df, timevar = "visit", idvar = "id", direction = "wide", v.names = "x")


##  unbalanced 'long' data leads to NA fill in 'wide' form
df2 <- df[1:7, ]
df2
reshape(df2, timevar = "visit", idvar = "id", direction = "wide")

## Alternative regular expressions for guessing names
df3 <- data.frame(id = 1:4, age = c(40,50,60,50), dose1 = c(1,2,1,2),
                  dose2 = c(2,1,2,1), dose4 = c(3,3,3,3))
reshape(df3, direction = "long", varying = 3:5, sep = "")


## an example that isn't longitudinal data
state.x77 <- as.data.frame(state.x77)
long <- reshape(state.x77, idvar = "state", ids = row.names(state.x77),
                times = names(state.x77), timevar = "Characteristic",
                varying = list(names(state.x77)), direction = "long")

reshape(long, direction = "wide")

reshape(long, direction = "wide", new.row.names = unique(long$state))

## multiple id variables
df3 <- data.frame(school = rep(1:3, each = 4), class = rep(9:10, 6),
                  time = rep(c(1,1,2,2), 3), score = rnorm(12))
wide <- reshape(df3, idvar = c("school","class"), direction = "wide")
wide
## transform back
reshape(wide)

}
\keyword{manip}
