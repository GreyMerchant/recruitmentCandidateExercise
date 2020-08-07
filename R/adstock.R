library(factory) #easily create a function factory

#' Create adstock function to use for media retention
#' @details Advertising adstock or advertising carry-over is the prolonged or
#' lagged effect of advertising. adstock returns a function with the required
#' retention factor built into it depending on specified value by the user which
#' can range from 0 to 1.
#' input variable
#' @param retention is a required numeric value to return the appropriate
#' adstock function which can range from 0 to 1.
#' @return A function is returned from a function factory after a value is
#' specified in \code{retention} which can only range from 0 to 1.
adstock <- build_factory(

  fun = function(x) {
    nx <- length(x)
    for (i in 1:nx) {
      if (i == 1) {
        res_1 <- x[i]
      }
      if (i > 1) {
        res_1 <- c(res_1, (x[i] + (retention * res_1[i - 1])))
      }
    }
    res_output <- as.vector(res_1)
  },
  retention
)


