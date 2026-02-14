# foreach(...) %do% { ... } =>
#   foreach(..., .options.future = <future arguments>) %dofuture% { ... }
#'
# times(...) %do% { ... } =>
#   local({
#     oopts <- options(future.disposable = <future arguments>)
#     on.exit(options(oopts))
#     times(...) %dofuture% { ... }
#   })
#
append_transpilers_for_doFuture <- function() {
  template_dofuture <- bquote_compile(local({
    oopts <- options(future.disposable = .(OPTS))
    on.exit(options(oopts))
    .(EXPR)
  }))
  
  template_times <- bquote_compile(local({
    oopts <- options(future.disposable = .(OPTS))
    on.exit(options(oopts))
    .(EXPR)
  }))
      
  transpiler <- eval(bquote(function(expr, options = NULL) {
    ## Replace `%do%` with doFuture::`%dofuture%`
    expr[[1]] <- quote(doFuture::`%dofuture%`)
    call <- expr[[2]]
    fcn <- call[[1]]
    
    ## times()?
    if (identical(fcn, as.symbol("times")) ||
        identical(fcn, quote(foreach::times))) {
      ## Default to seed = TRUE
      if (!"seed" %in% attr(options, "specified")) {
        options[["seed"]] <- TRUE
      }
      expr <- bquote_apply(template_dofuture,
        OPTS = options,
        EXPR = expr
      )
    } else {
      options <- make_options_for_doFuture(options, wrap = TRUE)
      if (identical(fcn, as.symbol("%:%")) ||
               identical(fcn, quote(foreach::`%:%`))) {
        idx_EXPR <- 2:3
      } else {
        idx_EXPR <- 2L
      }

      expr[[idx_EXPR]] <- append_call_arguments(expr[[idx_EXPR]],
        .args = options
      )
    }
    expr
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()
  transpilers[["%do%"]] <- list(
    label = "foreach::foreach() %do% { ... } -> foreach::foreach() %dofuture% { ... }",
    transpiler = transpiler
  )

  for (name in c("%dofuture%", "%dopar%")) {
    transpilers[[name]] <- list(
      label = sprintf("foreach::foreach() %s { ... } - not supported", name),
      transpiler = eval(bquote(function(...) {
        stop(sprintf("Cannot futurize foreach::foreach() %s { ... } - use %%do%% instead", .(name)))
      }))
    )
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "foreach"

  append_transpilers("futurize::add-on", transpilers)
  
  ## Return required packages
  c("doFuture")
}


make_options_for_doFuture <- local({
  defaults_base <- NULL

  function(options, defaults = NULL, wrap = TRUE) {
    ## Nothing to do?
    if (length(options) == 0 && length(defaults) == 0) return(options)

    if (is.null(defaults_base)) {
      ## The 'doFuture' package already imports 'future.apply'
      defaults_base <<- names(formals(future.apply::future_lapply))
    }

    if (length(defaults) > 0) {
      names <- setdiff(names(defaults), attr(options, "specified"))
      for (name in names) options[[name]] <- defaults[[name]]
    }

    names <- names(options)

    ## Remap chunk_size -> chunk.size
    idxs <- which(names == "chunk_size")
    if (length(idxs) > 0) names[idxs] <- "chunk.size"

    ## Remap future options for doFuture
    names <- sprintf("future.%s", names)

    ## Silently drop unknown future options
    keep <- intersect(defaults_base, names)
    idxs <- match(keep, table = names)
    options <- options[idxs]
    
    if (wrap) options <- list(.options.future = options)

    options
  }
})
