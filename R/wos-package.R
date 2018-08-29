#' wos
#' @name wos-package
#' @aliases wos-package wos
#' @docType package
#' @author Andy South
#' @keywords package
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
# copied from : https://github.com/jennybc/googlesheets/blob/master/R/googlesheets.R
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
