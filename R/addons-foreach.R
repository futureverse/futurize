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
  transpiler <- eval(bquote(function(expr, options = NULL) {
    ## Replace `%do%` with doFuture::`%dofuture%`
    expr[[1]] <- quote(doFuture::`%dofuture%`)
    call <- expr[[2]]
    fcn <- call[[1]]
    ## times()?
    if (identical(fcn, as.symbol("times")) ||
        identical(fcn, quote(foreach::times))) {
      expr2 <- quote(local({
        oopts <- options(future.disposable = OPTS)
        on.exit(options(oopts))
        EXPR
      }))
      idx_OPTS <- c(2L, 2L, 3L, 2L)
      idx_EXPR <- c(2L, 4L)
      
      ## SPECIAL CASE: Are we running via 'covr'?
      if (length(expr2[[c(2L, 2L, 3L)]]) > 2L) {
        idx_OPTS <- c(2L, 2L, 3L, 3L)
      }
      
      ## Default to seed = TRUE
      if (!"seed" %in% attr(options, "specified")) {
        options[["seed"]] <- TRUE
      }
      
      expr2[[idx_OPTS]] <- options
      expr2[[idx_EXPR]] <- expr
      expr <- expr2
    } else if (identical(fcn, as.symbol("%:%")) ||
               identical(fcn, quote(foreach::`%:%`))) {
      options <- make_options_for_doFuture(options, wrap = TRUE)
      idx_EXPR <- c(2L, 3L)
      parts <- c(as.list(expr[[idx_EXPR]]), options)
      expr[[idx_EXPR]] <- as.call(parts)
    } else {
      options <- make_options_for_doFuture(options, wrap = TRUE)
      idx_EXPR <- c(2L)
      parts <- c(as.list(expr[[idx_EXPR]]), options)
      expr[[idx_EXPR]] <- as.call(parts)
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
