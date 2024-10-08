% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/candidate_search.R
\name{candidate_search}
\alias{candidate_search}
\title{Candidate Search}
\usage{
candidate_search(
  FS,
  input_score,
  method = c("ks_pval", "ks_score", "wilcox_pval", "wilcox_score", "revealer", "knnmi",
    "correlation", "custom"),
  method_alternative = c("less", "greater", "two.sided"),
  cmethod = c("spearman", "pearson"),
  custom_function = NULL,
  custom_parameters = NULL,
  weights = NULL,
  search_start = NULL,
  top_N = 1,
  search_method = c("both", "forward"),
  max_size = 7,
  best_score_only = FALSE,
  do_plot = FALSE,
  verbose = FALSE
)
}
\arguments{
\item{FS}{a matrix of binary features or a SummarizedExperiment class object
from SummarizedExperiment package where rows represent features of interest
(e.g. genes, transcripts, exons, etc...) and columns represent the samples.
The assay of FS contains binary (1/0) values indicating the presence/absence
of omics features.}

\item{input_score}{a vector of continuous scores representing a phenotypic
readout of interest such as protein expression, pathway activity, etc.

NOTE: \code{input_score} object must have names or labels that match the
column names of \code{FS} object.}

\item{method}{a character string specifies a scoring method that is
used in the search. There are 7 options: (\code{"ks_pval"} or \code{ks_score}
or \code{"wilcox_pval"} or \code{wilcox_score} or
\code{"revealer"} (conditional mutual information from REVEALER) or
\code{"knnmi"} (K-Nearest Neighbor Mutual Information Estimator from knnmi) or
\code{"correlation"} (based on simple correlation - pearson or spearman) or
\code{"custom"} (a user-defined scoring method)).
Default is \code{ks_pval}.}

\item{method_alternative}{a character string specifies an alternative
hypothesis testing (\code{"two.sided"} or \code{"greater"} or \code{"less"}).
Default is \code{less} for left-skewed significance testing.

NOTE: This argument only applies to \code{ks_pval} and \code{wilcox_pval} method}

\item{cmethod}{correlation method to use - spearman or pearson. 
Default is "spearman".

NOTE: This argument only applies to \code{correlation} method only}

\item{custom_function}{if method is \code{"custom"}, specifies
a user-defined function here. Default is \code{NULL}.

NOTE: \code{custom_function} must take FS and input_score as its
input arguments and its final result must return a vector of row-wise scores
where its labels or names match the row names of \code{FS} object.}

\item{custom_parameters}{if method is \code{"custom"}, specifies a list of
additional arguments (excluding \code{FS} and \code{input_score})
to be passed to the \code{custom_function}. For example:
custom_parameters = list(alternative = "less"). Default is \code{NULL}.}

\item{weights}{if method is \code{ks_score} or \code{ks_pval}, specifying a
vector of weights will perform a weighted-KS testing. Default is \code{NULL}.

NOTE: \code{weights} must have names or labels that match the labels of
\code{input_score}.}

\item{search_start}{a vector of character strings (separated by commas)
specifies feature names in the \code{FS} object to start the search with.
If \code{search_start} is provided, then \code{top_N} parameter will be
ignored and vice versa. Default is \code{NULL}.}

\item{top_N}{an integer specifies the number of features to start the
search over. By default, it starts with the feature that has the highest
best score (top_N = 1).

NOTE: If \code{top_N} is provided, then \code{search_start} parameter
will be ignored and vice versa. If top_N > 10, it may result in a longer
search time.}

\item{search_method}{a character string specifies an algorithm to filter
out the best features (\code{"forward"} or \code{"both"}). Default is
\code{both} (i.e. backward and forward).}

\item{max_size}{an integer specifies a maximum size that a meta-feature
can extend to do for a given search. Default is \code{7}.}

\item{best_score_only}{a logical value indicates whether or not to return
the best score corresponding to each top N searches only.
Default is \code{FALSE}.}

\item{do_plot}{a logical value indicates whether or not to plot the
overlapping features of the resulting meta-feature matrix.

NOTE: plot can only be produced if the resulting meta-feature matrix contains
more than 1 feature (e.g. length(search_start) > 1 or top_N > 1).
Default is \code{FALSE}.}

\item{verbose}{a logical value indicates whether or not to print the
diagnostic messages. Default is \code{FALSE}.}
}
\value{
If \code{best_score_only = TRUE}, the heuristic search will return
the best feature whose its union meta-feature matrix has the highest score
among the \code{top_N} feature searches.
If \code{best_score_only = FALSE}, a list of objects pertaining to
\code{top_N} feature searches will be returned. For each top_N feature search,
the candidate search will contain 7 objects: (1) its best meta-feature matrix
(\code{feature_set}), (2) its observed input scores (\code{input_score}),
(3) its corresponding best score pertaining to the union meta-feature
matrix (\code{score}), (4) names of the best meta-features (\code{best_features}),
(5) rank of the best meta-features in term of their best scores (\code{best indices}),
(6) marginal scores of the best meta-features (\code{marginal_best_scores}),
(7) cumulative scores of the best meta-features (\code{cumulative_best_scores}).
}
\description{
Performs heuristic search on a set of binary features to determine whether
there are features whose union is more skewed (enriched at the extremes)
than either features alone. This is the main functionality of
the \code{CaDrA} package.
}
\details{
NOTE: The legacy function \code{topn_eval} is equivalent to the recommended
\code{candidate_search} function
}
\examples{

# Load pre-computed feature set
data(sim_FS)

# Load pre-computed input scores
data(sim_Scores)

# Define additional parameters and run the function
candidate_search_result <- candidate_search(
  FS = sim_FS, input_score = sim_Scores,
  method = "ks_pval", method_alternative = "less", weights = NULL,
  search_start = NULL, top_N = 3, search_method = "both",
  max_size = 7, best_score_only = FALSE
)

}
