#'
#' Wilcoxon Rank Sum Scoring Method
#'
#' Compute directional Wilcoxon rank sum score for each row of a
#' given binary feature matrix
#'
#' @param FS a matrix of binary features where rows represent features of 
#' interest (e.g. genes, transcripts, exons, etc...) and columns represent 
#' the samples.
#' @param input_score a vector of continuous scores representing a phenotypic
#' readout of interest such as protein expression, pathway activity, etc.
#' The \code{input_score} object must have names or labels that match the column
#' names of FS object.
#' @param meta_feature a vector of one or more features representing known 
#' causes of activation or features associated with a response of interest
#' (\code{e.g. input_score}). Default is NULL.
#' @param alternative a character string specifies an alternative
#' hypothesis testing (\code{"two.sided"} or \code{"greater"} or
#' \code{"less"}). Default is \code{less} for left-skewed significance testing.
#' @param metric a character string specifies a metric to search for 
#' best features. \code{"pval"} or \code{"stat"} may be used which is 
#' corresponding to p-value or score statistic. Default is \code{pval}. 
#'  
#' @noRd
#' 
#' @examples 
#'  
#' mat <- matrix(c(1,0,1,0,0,0,0,0,1,0, 
#'                 0,0,1,0,1,0,1,0,0,0,
#'                 0,0,0,0,1,0,1,0,1,0), nrow=3)
#'
#' colnames(mat) <- 1:10
#' row.names(mat) <- c("TP_1", "TP_2", "TP_3")
#'
#' set.seed(42)
#' input_score = rnorm(n = ncol(mat))
#' names(input_score) <- colnames(mat)
#'
#' wilcox_rs <- wilcox_rowscore(
#'    FS = mat,
#'    input_score = input_score,
#'    meta_feature = NULL,
#'    alternative = "less",
#'    metric = "pval"
#' )
#'
#' @return return a vector of row-wise scores where its labels or names 
#' must match the row names of \code{FS} object
#' 
wilcox_rowscore <- function
(
  FS,
  input_score,
  meta_feature = NULL,
  alternative = c("less", "greater", "two.sided"),
  metric = c("stat", "pval")
)
{

  metric <- match.arg(metric)
  alternative <- match.arg(alternative)
  
  # Check if meta_feature is provided
  if(!is.null(meta_feature)){
    # Getting the position of the known meta features
    locs <- match(meta_feature, row.names(FS))
    
    # Taking the union across the known meta features
    if(length(locs) > 1) {
      meta_vector <- as.numeric(ifelse(colSums(FS[locs,]) == 0, 0, 1))
    }else{
      meta_vector <- as.numeric(FS[locs,])
    }
    
    # Remove the meta features from the binary feature matrix
    # and taking logical OR btw the remaining features with the meta vector
    FS <- base::sweep(FS[-locs, , drop=FALSE], 2, meta_vector, `|`)*1
    
    # Check if there are any features that are all 1s generated from
    # taking the union between the matrix
    # We cannot compute statistics for such features and thus they need
    # to be filtered out
    if(any(rowSums(FS) == ncol(FS))){
      warning("Features with all 1s generated from taking the matrix union ",
              "will be removed before progressing...\n")
      FS <- FS[rowSums(FS) != ncol(FS), , drop=FALSE]
    }
  }
  
  # Wilcox is a ranked-based method
  # So we need to sort input_score from highest to lowest values
  input_score <- sort(input_score, decreasing=TRUE)
  
  # Re-order the matrix based on the order of input_score
  FS <- FS[, names(input_score), drop=FALSE]  
  
  # Since input_score is already ordered from largest to smallest
  # We can assign ranks as 1:N (N: number of samples)
  ranks <- seq(1, ncol(FS))

  # Compute the wilcox rank sum statitic and p-value per row in the matrix
  wilcox <- apply(X=FS, MARGIN=1, function(x){
    wilcox_score(
      x = ranks[which(x==1)],
      y = ranks[which(x==0)],
      alternative = alternative
    )
  })
  
  # Obtain score statistics from KS method
  # Change values of 0 to the machine lowest value to avoid taking -log(0)
  stat <- wilcox[1,]
  
  # Obtain p-values from KS method
  # Change values of 0 to the machine lowest value to avoid taking -log(0)
  pval <- wilcox[2,]
  pval[which(pval == 0)] <- .Machine$double.xmin

  # Compute the scores according to the provided metric
  scores <- ifelse(rep(metric, nrow(FS)) %in% "pval", -log(pval), stat)
  names(scores) <- rownames(FS)
  
  return(scores)
  
}



#' Compute rank sum scores for a given binary feature
#'
#' @param x an integer ranked values for group 1
#' @param y an integer ranked values for group 2
#' @param mu a number uses as an optional parameter to form a null hypothesis.
#' Default is \code{0}.
#' @param alternative alternative hypothesis for p-value calculation
#' (\code{"two.sided"} or \code{"greater"} or \code{"less"}).
#' Default is \code{less} for left-skewed significance testing.
#' @param paired whether to perform paired test. Default is \code{FALSE}.
#' @param exact whether to compute exact p-value. Default is \code{FALSE}.
#' @param correct whether to consider continuity correction for p-value.
#' Default is \code{TRUE}.
#'
#' @noRd
#'
#' @return a vector with two values: \code{score} and \code{p_value}
#'
#' @importFrom stats pnorm pwilcox
wilcox_score <- function
(
  x,
  y,
  mu = 0,
  alternative = c("less", "greater", "two.sided"),
  paired = FALSE,
  exact = FALSE,
  correct = TRUE
)
{

  alternative <- match.arg(alternative)
  
  if (!missing(mu) && ((length(mu) > 1L) || !is.finite(mu)))
    stop("'mu' must be a single number")
  if (!is.numeric(x))
    stop("'x' must be numeric")
  if (!is.numeric(y))
    stop("'y' must be numeric")

  DNAME <- paste(deparse(substitute(x)), "and", deparse(substitute(y)))

  x <- x[is.finite(x)]
  y <- y[is.finite(y)]

  if (length(x) < 1L) {
    #print(x)
    stop("not enough (finite) 'x' observations")}

  if (length(y) < 1L){
    #print(y)
    stop("not enough 'y' observations")}

  METHOD <- "Wilcoxon rank sum test"

  ##### Modification ######
  # Take input as ranks instead of continuous measures
  # (normally internally ranked: see below)
  r <- c(x,y)

  #r <- rank(c(x - mu, y))

  n.x <- as.double(length(x))
  n.y <- as.double(length(y))

  if (is.null(exact))
    exact <- (n.x < 50) && (n.y < 50)

  STATISTIC <- c(W = sum(r[seq_along(x)]) - n.x * (n.x + 1)/2)
  TIES <- (length(r) != length(unique(r)))

  if (exact && !TIES) {

    PVAL <- switch(alternative, two.sided = {
      p <- if (STATISTIC > (n.x * n.y/2))
        pwilcox(STATISTIC - 1, n.x, n.y,
                lower.tail = FALSE) else pwilcox(STATISTIC, n.x, n.y)
      min(2 * p, 1)
    }, greater = {
      pwilcox(STATISTIC - 1, n.x, n.y, lower.tail = FALSE)
    }, less = pwilcox(STATISTIC, n.x, n.y))

  } else {

    NTIES <- table(r)
    z <- STATISTIC - n.x * n.y/2
    SIGMA <- sqrt((n.x * n.y/12) * ((n.x + n.y + 1) -
                                      sum(NTIES^3 - NTIES)/
                                      ((n.x + n.y) * (n.x + n.y - 1))))

    if (correct) {
      CORRECTION <- switch(alternative, two.sided = sign(z) *
                             0.5, greater = 0.5, less = -0.5)
      METHOD <- paste(METHOD, "with continuity correction")
    }

    z <- (z - CORRECTION)/SIGMA

    PVAL <- switch(alternative, less = pnorm(z),
                   greater = pnorm(z, lower.tail = FALSE),
                   two.sided = 2 * min(pnorm(z),
                                       pnorm(z, lower.tail = FALSE)))

    if (exact && TIES)
      warning("cannot compute exact p-value with ties")

  }

  names(mu) <- ifelse (paired || !is.null(y), "location shift", "location")

  RVAL <- list(statistic = STATISTIC,
               parameter = NULL, p.value = as.numeric(PVAL),
               null.value = mu, alternative = alternative, method = METHOD,
               data.name = DNAME)

  class(RVAL) <- "htest"

  return(c(score=RVAL$statistic, p_value=RVAL$p.value))

}

