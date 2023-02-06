
test_that("custom_rowscore returns correct results", {
  
  
  mat <- matrix(c(1,0,1,0,0,0,0,0,1,0, 
                  0,0,1,0,1,0,1,0,0,0,
                  0,0,0,0,1,0,1,0,1,0), nrow=3)
  
  colnames(mat) <- 1:10
  row.names(mat) <- c("TP_1", "TP_2", "TP_3")
  
  set.seed(42)
  input_score = rnorm(n = ncol(mat))
  names(input_score) <- colnames(mat)
  custom_function <- wilcox_rowscore
  
  
  result <- custom_rowscore(
    FS_mat = mat, 
    input_score = input_score,
    custom_function = wilcox_rowscore,
    method = "custom_pval", 
    custom_parameters = list(alternative="less")
  )
  
  testthat::expect_identical(dim(result), c(3L,2L))
  testthat::expect_type(result, "double")
  testthat::expect_identical(rownames(result), row.names(mat))
  testthat::expect_identical(colnames(result), c("score","p_value"))
  testthat::expect_identical(result[,1], c(TP_1=3,TP_2=13,TP_3=5))
  testthat::expect_equal(round(result[,2], 3), c(TP_1=0.055, TP_2=0.925, TP_3=0.083) )
  
  
})

## --------------------------------------------------- ##
test_that("custom_rowscore issues error messages when needed", {
  
  mat <- matrix(c(1,0,1,0,0,0,0,0,1,0, 
                  0,0,1,0,1,0,1,0,0,0,
                  0,0,0,0,1,0,1,0,1,0), nrow=3)
  
  colnames(mat) <- 1:10
  row.names(mat) <- c("TP_1", "TP_2", "TP_3")
  
  set.seed(42)
  input_score = rnorm(n = ncol(mat))
  names(input_score) <- colnames(mat)
  custom_function <- wilcox_rowscore

  # error if custom function is not given 
  expect_error( custom_rowscore(
      FS_mat = mat, 
      input_score = input_score,
      custom_function = "wilcox_rowscore",
      method = "custom_pval", 
      custom_parameters = list(alternative="less") )
  )
  
  # error if custom parameters are not given in a list
  expect_error( custom_rowscore(
    FS_mat = mat, 
    input_score = input_score,
    custom_function = custom_function,
    method = "custom_pval", 
    custom_parameters = c(alternative="less") )
  )
  
  # error if function does not have "FS_mat" and "input_list" arguments
  err_function <- function(FS_mat){ return(0)}
  expect_error( custom_rowscore(
    FS_mat = mat, 
    input_score = input_score,
    custom_function = err_function,
    method = "custom_pval")
  )
  err_function <- function(input_score){ return(0)}
  expect_error( custom_rowscore(
    FS_mat = mat, 
    input_score = input_score,
    custom_function = err_function,
    method = "custom_pval")
  )
  
  
  
})