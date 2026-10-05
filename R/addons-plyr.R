# plyr::llply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), withCallingHandlers(
#   plyr::llply(xs, fcn,
#     .parallel = TRUE,
#     .paropts = list(.options.future = <future arguments>)
#   ),
#   warning = <muffle plyr's "No parallel backend registered" warning>
# ))
#
append_transpilers_for_plyr <- function() {
  template <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), (withCallingHandlers(
      .(EXPR),
      warning = function(w) {
        ## plyr warns "No parallel backend registered" when
        ## nbrOfWorkers() == 1, e.g. plan(sequential)
        if (identical(conditionCall(w), quote(setup_parallel()))) {
          invokeRestart("muffleWarning")
        }
      }
    )))
  )

  template2 <- bquote_compile(function(expr, options = NULL) {
    defaults <- list(label = sprintf("fz:plyr::%s-%%d", .(NAME)))
    options <- make_options_for_doFuture(options, defaults = defaults, wrap = TRUE)
    paropts <- expr[[".paropts"]]
    if (is.null(paropts)) {
      expr <- append_call_arguments(expr,
        .parallel = TRUE,
        .paropts = options
      )
    } else {
      ## Add futurize options to the parallel options of the user
      expr[[".paropts"]] <- merge_paropts_call(paropts, options = options)
      expr <- append_call_arguments(expr, .parallel = TRUE)
    }
    bquote_apply(template, EXPR = expr)
  })

  transpilers <- make_package_transpilers("plyr", FUN = function(fcn, name) {
    if (".parallel" %in% names(formals(fcn))) {
      transpiler <- eval(bquote_apply(template2, NAME = name))
      list(
        label = sprintf("plyr::%s() ~> plyr::%s(..., parallel = TRUE)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("plyr", "doFuture")
}


#' Create an expression adding futurize options to plyr's '.paropts'
#'
#' @param paropts An \R expression hold a '.paropts' expression.
#'
#' @param options A named list with element `.options.future`.
#'
#' @return
#' The \R expression with `options` appended.
#' If `paropts` specified `.options.future`, then an error is thrown.
#'
#' @noRd
merge_paropts_call <- function(paropts, options) {
  bquote(local({
    paropts <- as.list(.(paropts))
    if (".options.future" %in% names(paropts)) {
      stop("Cannot futurize plyr functions called with .paropts = list(.options.future = ...). Instead, pass future options to futurize(), e.g. futurize(seed = TRUE)", call. = FALSE)
    }
    c(paropts, .(options))
  }))
} ## merge_paropts_call()
