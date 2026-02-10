#' Turn common R function calls into concurrent calls for parallel evaluation
#'
#' \if{html}{\figure{futurize-logo.png}{options: style='float: right;' alt='logo' width='120'}}
#'
#' @inheritParams future::future
#'
#' @param expr An \R expression, typically a function call to futurize.
#' If FALSE, then futurization is disabled, and if TRUE, it is
#' re-enabled.
#'
#' @param options,\ldots Named options, passed to [futurize_options()],
#' controlling how futures are resolved.
#' 
#' @param when If TRUE (default), the expression is futurized, otherwise not.
#'
#' @param eval If TRUE (default), the futurized expression is evaluated,
#' otherwise it is returned.
#'
#' @returns
#' Returns the value of the evaluated expression `expr`.
#'
#' If `expr` is TRUE or FALSE, then a logical is returned indicating 
#' whether futurization was previously enabled or disabled.
#'
#'
#' @section Expression unwrapping:
#' The transpilation mechanism includes logic to "unwrap" expressions
#' enclosed in constructs such as `{ }`, `( )`, `local()`, `I()`,
#' `identity()`, `invisible()`, `suppressMessages()`, and
#' `suppressWarnings()`. The transpiler descends through wrapping
#' constructs until it finds a transpilable expression, avoiding the
#' need to place `futurize()` inside such constructs. This allows for
#' patterns like:
#'
#' ```r
#' y <- {
#'   lapply(xs, fcn)
#' } |> suppressMessages() |> futurize()
#' ```
#'
#' avoiding having to write:
#'
#' ```r
#' y <- {
#'   lapply(xs, fcn) |> futurize()
#' } |> suppressMessages()
#' ```
#'
#'
#' @section Conditional futurization:
#' It is possible to control whether futurization should take place at
#' run-time. For example,
#'
#' ```r
#' y <- lapply(xs, fun) |> futurize(when = { length(xs) >= 10 })
#' ```
#'
#' will be futurized, unless `length(xs)` is less than ten, in which case it is
#' evaluated as:
#'
#' ```r
#' y <- lapply(xs, fun)
#' ```
#'
#'
#' @section Disable and re-enable all futurization:
#' It is possible to globally disable the effect of all `futurize()` calls
#' by calling `futurize(FALSE)`. The effect is as if `futurize()` was never
#' applied. For example,
#'
#' ```r
#' futurize(FALSE)
#' y <- lapply(xs, fun) |> futurize()
#' ```
#'
#' evaluates as:
#'
#' ```r
#' y <- lapply(xs, fun)
#' ```
#'
#' To re-enable futurization, call `futurize(TRUE)`.
#' Please note that it is only the end-user that may control whether
#' futurization should be disabled and enabled. A package must _never_
#' disable or enable futurization.
#'
#'
#' @example incl/futurize.R
#'
#' @seealso
#' To see which CRAN and Bioconductor packages are supported, use
#' [futurize_supported_packages()].
#' To see which functions a specific package supports, use
#' [futurize_supported_functions()].
#'
#' @aliases fz
#' @export
futurize <- function(expr, substitute = TRUE, options = futurize_options(...), ..., when = TRUE, eval = TRUE, envir = parent.frame()) {
  if (substitute) expr <- substitute(expr)
  debug <- isTRUE(getOption("futurize.debug"))
  if (debug) {
    mdebug_push("futurize() ...")
    on.exit(mdebug_pop())
  }

  transpile(expr, substitute = FALSE, options = options, when = when, eval = eval, type = "futurize::add-on", envir = envir, what = "futurize", debug = debug)
} ## futurize()
class(futurize) <- c("transpiler", class(futurize))


#' @export
fz <- futurize
