
#' Calculate row-wise scores of a given binary feature set based on
#' an appropriate scoring method
#'
#' @param FS a SummarizedExperiment object containing
#' binary features where rows represent features of interest
#' (e.g. genes, transcripts, exons, etc...) and columns represent the samples.
#' @param input_score a vector of continuous scores representing a phenotypic
#' readout of interest such as protein expression, pathway activity, etc.
#' The \code{input_score} object must have names or labels that match the column
#' names of FS object.
#' @param method a character string specifies a scoring method that is
#' used in the search. There are 4 options: (\code{"ks"} or \code{"wilcox"} or
#' \code{"revealer"} (conditional mutual information from REVEALER) or
#' \code{"custom"} (a user-customized scoring method)). Default is \code{ks}.
#' @param alternative a character string specifies an alternative hypothesis
#' testing (\code{"two.sided"} or \code{"greater"} or \code{"less"}).
#' Default is \code{less} for left-skewed significance testing.
#' NOTE: \code{Revealer} method only returns score statistics (no p-values).
#' @param weight if method is \code{ks}, specifies a vector of weights
#' to perform a weighted-KS testing. Default is \code{NULL}.
#' @param seed_names one or more features representing known “causes”
#' of activation or features associated with a response of interest.
#' It is used for \code{method = revealer} only.
#' @param custom_function if method is \code{"custom"}, just pass the name of the
#' customized function. Default is \code{NULL}.
#' @param custom_parameters if method is \code{"custom"}, specifies a list of
#' additional arguments (other than \code{FS} and \code{input_score}) to be passed
#' to the \code{custom_function()}. Default is \code{NULL}.
#' @param do_check a logical value indicates whether or not to check
#' diagnostic messages. Default is \code{TRUE}
#' 
#' @return a matrix containing row-wise directional scores from a given 
#' scoring method
#' @examples
#'
#' # Load pre-computed feature set
#' data(sim_FS)
#'
#' # Load pre-computed input-score
#' data(sim_Scores)
#'
#' # Run the ks method
#' ks_rowscore_result <- calc_rowscore(
#'   FS = sim_FS,
#'   input_score = sim_Scores,
#'   method = "ks",
#'   weight = NULL,
#'   alternative = "less"
#' )
#'
#' # Run the wilcoxon method
#' wilcox_rowscore_result <- calc_rowscore(
#'   FS = sim_FS,
#'   input_score = sim_Scores,
#'   method = "wilcox",
#'   alternative = "less"
#' )
#'
#' # Run the revealer method
#' revealer_rowscore_result <- calc_rowscore(
#'   FS = sim_FS,
#'   input_score = sim_Scores,
#'   method = "revealer",
#'   seed_names = NULL
#' )
#'
#' @export
#' @import SummarizedExperiment
calc_rowscore <- function(
    FS,
    input_score,
    method = c("ks", "wilcox", "revealer", "custom"),
    alternative = c("less", "greater", "two.sided"),
    weight,
    seed_names = NULL,
    custom_function,
    custom_parameters,
    do_check = TRUE
){

  # Match arguments
  method <- match.arg(method)
  alternative <- match.arg(alternative)

  # Select the appropriate method to compute row-wise directional scores
  score <- switch(
    method,
    ks = ks_rowscore(
      FS = FS,
      input_score = input_score,
      weight = weight,
      alternative = alternative,
      do_check = do_check
    ),
    wilcox = wilcox_rowscore(
      FS = FS,
      input_score = input_score,
      alternative = alternative,
      do_check = do_check
    ),
    revealer = revealer_rowscore(
      FS = FS,
      input_score = input_score,
      seed_names = seed_names,
      assoc_metric = "IC",
      do_check = do_check
    ),
    custom = custom_rowscore(
      FS = FS,
      input_score = input_score,
      custom_function = custom_function,
      custom_parameters = custom_parameters,
      do_check = do_check
    )
  )

  return(score)

}


