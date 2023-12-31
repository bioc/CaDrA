% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/topn_plot.R
\name{topn_plot}
\alias{topn_plot}
\title{Top 'N' Plot}
\usage{
topn_plot(topn_list)
}
\arguments{
\item{topn_list}{a list of objects obtained from \code{candidate_search} 
using the following parameters: \code{FS = sim_FS}, 
\code{input_score = sim_Scores}, \code{top_N = 7}, 
\code{method = "ks_pval"}, \code{alternative = "less"}, 
\code{search_method = "both"}, \code{max_size = 10},
and \code{best_score_only = FALSE}.}
}
\value{
a heatmap of overlapping meta-features across top N 
feature searches
}
\description{
Generate a heatmap representation of overlapping meta-features across
top N feature searches using \code{candidate_search} function
}
\examples{

# Load pre-computed Top-N list generated for sim_FS dataset
data(topn_list)

# Get the overlapping top N plot
topn_plot(topn_list = topn_list)

}
