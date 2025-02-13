\name{makeDataTypes}
\alias{makeDataTypes}
\alias{getDataTypes}
\alias{getDaisyTypes}
\title{
Discretize a Continuous Data Set to Mixed Types
}
\description{
The makeDataTypes function allows the user to discretize a continuous data set
generated from an engine of any type into binary, nominal, ordinal, or mixed-type data.
}
\usage{
makeDataTypes(dataset, pCont, pBin, pCat, pNominal = 0.5,
             range = c(3, 9), exact = FALSE, inputRowsAreFeatures = TRUE)
getDataTypes(object)
getDaisyTypes(object)
}
\arguments{
  \item{dataset}{A matrix or dataframe of continuous data.}
  \item{pCont}{
    Non-negative, numeric probability equal to or between 0 and 1
    describing desired percent frequency of continuous features.
}
  \item{pBin}{
    Non-negative, numeric probability equal to or between 0 and 1
    describing desired percent frequency of binary features.
}
  \item{pCat}{
    Non-negative, numeric probability equal to or between 0 and 1
    describing desired percent frequency of categorical features.
}
  \item{pNominal}{
    Non-negative, numeric probability equal to or between 0 and 1
    describing desired percent frequency of categorical features to
    be simulated as nominal.
}
  \item{range}{
    A set of integers whose minimum and maximum determine the range of
    the number of levels to be associated with simulated  categorical
    factors.
}
  \item{exact}{
    A logical value; should the parameters \code{pCont}, \code{pBin}
    and \code{pCat} be treated  as exact fractions to achieve or as
    probabilities.
}
  \item{inputRowsAreFeatures}{
    Logical value indicating if features are to be simulated as rows 
    (TRUE) or columns (FALSE).
  }
  \item{object}{An object of the \code{MixedTypeEngine} class.}
}
\details{The \code{makeDataTypes} function is a critical step in the
  construction of a \code{\link{MixedTypeEngine}}, which is an object
  that is used to simulate clinical mixed-type data instead of gene
  expression data. The standard process, as illustrated in the example,
  involves (1) creating a \code{\link{ClinicalEngine}}, (2) generating a
  random data set from that engine, (3) adding noise, (4) setting the
  data types, and finally (5) creating the \code{MixedTypeEngine}.

  The main types of data (continuous, binary, or categorical) are
  randomly assigned using the probability parameters \code{pCont},
  \code{pBin}, and \code{pCat}. To choose the splitting point for the
  binary features, we compute the bimodality index (Wang et al.). If that
  is significant, we split the data halfway between the two
  modes. Otherwise, we choose a random split point between 5\% and
  35\%. Categorical data is also randomly assigned to ordinal or nominal
  based on the \code{pNominal} parameter. The number of levels is
  uniformly selected in the specified \code{range}, and the fraction of
  data points assigned to each level is selected from a Dirichlet
  distribution with alpha = c(20, 20, ..., 20).

}
\value{
  A list containing:
  \item{binned }{An object of class data.frame of simulated, mixed-type data.}
  \item{cutpoints }{
      An object of class "list". For each feature, data type, labels (if data are 
      binary or categorical), and break points (if data are binary or categorical) 
      are stored. Cutpoints can be passed to a \code{\link{MixedTypeEngine}} 
      for storage and downstream use.
      }
  The \code{getDataTypes} function returns a character vector listing
  the type of data for each feature in a \code{MixedTypeEngine}. the
  \code{getDaisyTypes} function converts this vector to a list suitable
  for input to the \code{\link[cluster]{daisy}} function in the \code{cluster}
  package.
}
\references{
Wang J, Wen S, Symmans WF, Pusztai L, Coombes KR. \cr\emph{The bimodality index: A criterion for discovering and ranking bimodal signatures from cancer gene expression profiling data.}\cr Cancer Inform 2009; 7:199-216.
}
\author{
  Kevin R. Coombes \email{krc@silicovore.com},
  Caitlin E. Coombes \email{caitlin.coombes@osumc.edu}
}
\note{
If \code{pCont}, \code{pBin}, and \code{pCat} do not sum to 1, they will be rescaled.

By default, categorical variables are simulated as a mixture of nominal
and ordinal data. The remaining categorical features described by
\code{pNominal} are simulated as ordinal.
}
\seealso{
  \code{\link{MixedTypeEngine}}
}
\examples{
## Create a ClinicalEngine with 4 clusters
ce <- ClinicalEngine(20, 4, TRUE)

## Generate continuous data
set.seed(194718)
dset <- rand(ce, 300)

## Add noise before binning mixed type data
cnm <- ClinicalNoiseModel(nrow(ce@localenv$eng)) # default
noisy <- blur(cnm, dset$data)

## Set the data mixture
dt <- makeDataTypes(dset$data, 1/3, 1/3, 1/3, 0.3)
cp <- dt$cutpoints
type <- sapply(cp, function(X) { X$Type })
table(type)
summary(dt$binned)

## Use the pieces from above to create an MTE.
mte <- MixedTypeEngine(ce,
           noise = cnm,
           cutpoints = dt$cutpoints)
## and generate some data with the same data types and cutpoints
R <- rand(mte, 20)
summary(R)
}
\keyword{classes}
\keyword{datagen}
