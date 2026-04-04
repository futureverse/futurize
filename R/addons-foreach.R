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
  template <- bquote_compile(local({
    oopts <- options(future.disposable = .(OPTS))
    on.exit(options(oopts))
    .(EXPR)
  }))
  
  transpiler <- function(expr, options = NULL) {
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
      if (!"label" %in% attr(options, "specified")) {
        options[["label"]] <- "fz:foreach::times-%d"
      }
      expr <- bquote_apply(template,
        OPTS = options,
        EXPR = expr
      )
    } else {
      if (identical(fcn, as.symbol("%:%")) ||
                  identical(fcn, quote(foreach::`%:%`))) {
        name <- "%:%"
        label <- "%%:%%"
      } else {
        name <- "foreach"
        label <- "foreach"
      }
      defaults <- list(label = sprintf("fz:foreach::%s-%%d", label))
      options <- make_options_for_doFuture(options, defaults = defaults, wrap = TRUE)
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
  }

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
