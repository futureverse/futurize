#' List packages and functions supporting futurization
#'
#' @param package A package name.
#'
#' @return
#' A character vector of package or function names
#'
#' @examples
#' pkgs <- futurize_supported_packages()
#' pkgs
#'
#' fcns <- futurize_supported_functions("base")
#' fcns
#'
#' @export
futurize_supported_packages <- function() {
  db <- transpiler_packages(classes = c("futurize::add-on"))
  sort(unique(db[["package"]]))
}


#' @rdname futurize_supported_packages
#' @export
futurize_supported_functions <- function(package) {
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
