# fwb::fwb(...) =>
#
# local({
#   fwb::fwb(..., cl = "future")
# })
#
append_transpilers_for_fwb <- function() {
  package <- "fwb"

  template <- bquote_compile(
   local({
      ## This will be automatically consumed and removed by 'future.apply',
      ## which pblapply() calls, which fwb() calls.
      options(future.disposable = structure(.(OPTS), dispose = FALSE))
      ...future_old_rngkind <- RNGkind("L'Ecuyer-CMRG")
      on.exit({
        do.call(RNGkind, args = as.list(...future_old_rngkind))
        options(future.disposable = NULL)
      })
      .(EXPR)
    })
  )
  
  transpiler <- function(expr, options = NULL, defaults = list(seed = TRUE)) {
    ## Specified future.* arguments
    specified <- attr(options, "specified")

    names(options) <- sub("chunk_size", "chunk.size", names(options), fixed = TRUE)
    
    ## pbapply does not handle stdout, messages, and warnings, so disable
    ## those by default
    if (!"stdout" %in% specified) {
      options$stdout <- FALSE
    }
    if (!"conditions" %in% specified) {
      options$conditions <- structure(options$conditions,
                               exclude = c("message", "warning"))
    }

    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) {
        if (name == "packages") {
          options[[name]] <- c(options[[name]], defaults[[name]])
        } else {
          options[[name]] <- defaults[[name]]
        }
      }
    }
    
    expr <- append_call_arguments(expr,
      cl = "future"
    )
    
    bquote_apply(template,
      OPTS = options,
      EXPR = expr
    )
  }
  body(transpiler) <- body(transpiler)

  transpilers <- make_package_transpilers(package, FUN = function(fcn, package, name) {
    if ("cl" %in% names(formals(fcn))) {
      list(
        label = sprintf("%s::%s() ~> %s::%s(..., cl = \"future\")", package, name, package, name),
        transpiler = transpiler
      )
    }
  })

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "future")
}
