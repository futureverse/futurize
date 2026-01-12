#' Evaluate common R functions in parallel
#'
#' \if{html}{\figure{futurize-magic-touch-parallelization-120x138.png}{options: style='float: right;' alt='logo' width='120'}}
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
#' If `expr` is a TRUE or FALSE, then a logical is returned indicating 
#' whether futurization was previously enabled or disabled.
#'
#'
#' @section Conditionally futurization:
#' It is possible to control whether futurization should take place at
#' run-time. For example,
#'
#' ```r
#' y <- lapply(xs, fun) |> futurize(when = { length(xs) >= 10 })
#' ```
#'
#' will be futurized, unless `length(xs)` less than ten, in case it is
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
#' is evaluates as:
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
#' @aliases parallelize
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



#' List packages and functions supporting futurization
#'
#' @param package A package name.
#'
#' @return
#' A character vector of package or function names
#'
#' @examples
#' pkgs <- supported_packages()
#' pkgs
#'
#' fcns <- supported_package_functions("base")
#' fcns
#'
#' @export
supported_packages <- function() {
  db <- transpiler_packages(classes = c("futurize::add-on"))
  sort(unique(db[["package"]]))
}


#' @rdname supported_packages
#' @export
supported_package_functions <- function(package) {
  stopifnot(is.character(package), length(package) == 1L, !is.na(package), nzchar(package))
  
  db <- transpilers_for_package(action = "list")
  classes <- c("futurize::add-on")
  if (!is.null(classes)) {
    db <- db[names(db) %in% classes]
  }
  classes <- names(db)

  packages <- package
  if (!requireNamespace(package, quietly = TRUE)) {
    stop("Package is not installed: ", sQuote(package))
  }
  
  ## Special cases
  if (package == "stats") packages <- c(packages, "base")
  fcns <- lapply(classes, function(class) {
    ## "Activate" packages
    void <- lapply(packages, function(pkg) {
      activators <- db[[class]][[pkg]]
      lapply(activators, FUN = function(activator) activator())
    })
    transpilers <- get_transpilers(class)
    transpilers <- transpilers[names(transpilers) == package]
    names <- lapply(transpilers, FUN = names)
    names <- unlist(names, use.names = FALSE)
    names <- unique(sort(names))
    names
  })
  fcns <- unlist(fcns, use.names = TRUE)

  ns <- getNamespace(package)
  keep <- vapply(fcns, FUN.VALUE = FALSE, FUN = function(fcn) {
    exists(fcn, mode = "function", envir = ns, inherits = FALSE)
  })
  fcns <- fcns[keep]

  if (length(fcns) == 0) {
    stop(sprintf("Package %s does not support futurization", sQuote(package)))
  }

  fcns
}
