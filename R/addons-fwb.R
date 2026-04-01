# fwb::fwb(...) =>
#
# local({
#   fwb::fwb(..., cl = "future")
# })
#
append_transpilers_for_fwb <- function() {
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
  
  template2 <- bquote_compile(function(expr, options = NULL) {
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

    defaults <- list(
      seed = TRUE,
      label = sprintf("fz:fwb::%s-%%d", .(NAME))
    )
    names <- setdiff(names(defaults), attr(options, "specified"))
    for (name in names) {
      if (name == "packages") {
        options[[name]] <- c(options[[name]], defaults[[name]])
      } else {
        options[[name]] <- defaults[[name]]
      }
    }
    
    expr <- append_call_arguments(expr,
      cl = "future"
    )
    
    bquote_apply(template,
      OPTS = options,
      EXPR = expr
    )
  })

  transpilers <- make_package_transpilers("fwb", FUN = function(fcn, name) {
    if ("cl" %in% names(formals(fcn))) {
      transpiler <- eval(bquote_apply(template2, NAME = name))

      list(
        label = sprintf("fwb::%s() ~> fwb::%s(..., cl = \"future\")", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("fwb", "future")
}
