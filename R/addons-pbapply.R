# pbapply::pblapply(xs, fcn, ...) =>
#
# local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   pbapply::pblapply(xs, fcn, ..., cl = "future")
# })
#
append_transpilers_for_pbapply <- function() {
  template <- bquote_compile(
   local({
      ## This will be automatically consumed and removed by 'future.apply'
      options(future.disposable = structure(.(OPTS), dispose = FALSE))
      on.exit(options(future.disposable = NULL))
      .(EXPR)
    })
  )

  template2 <- bquote_compile(function(expr, options = NULL) {
    ## Specified future.* arguments
    specified <- attr(options, "specified")

    names(options) <- sub("chunk_size", "chunk.size", names(options), fixed = TRUE)
     if (!"label" %in% specified && !"label" %in% names(options)) {
      options[["label"]] <- sprintf("fz:pbapply::%s-%%d", .(NAME))
    }

    ## pbapply does not handle stdout, messages, and warnings, so disable
    ## those by default
    if (!"stdout" %in% specified) {
      options$stdout <- FALSE
    }
    if (!"conditions" %in% specified) {
      options$conditions <- structure(options$conditions,
                               exclude = c("message", "warning"))
    }

    expr <- append_call_arguments(expr,
      cl = "future"
    )

    bquote_apply(template, OPTS = options, EXPR = expr)
  })

  transpilers <- make_package_transpilers("pbapply", FUN = function(fcn, name) {
    if ("cl" %in% names(formals(fcn))) {
      transpiler <- eval(bquote_apply(template2, NAME = name))

      list(
        label = sprintf("pbapply::%s() ~> pbapply::%s(..., cl = \"future\")", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("pbapply")
}
