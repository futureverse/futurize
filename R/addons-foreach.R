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
  
  ## All foreach() calls in a, possibly nested, foreach() %:% foreach() chain
  foreach_calls <- function(call) {
    if (is.call(call) &&
        (identical(call[[1]], as.symbol("%:%")) ||
         identical(call[[1]], quote(foreach::`%:%`)))) {
      c(foreach_calls(call[[2]]), foreach_calls(call[[3]]))
    } else {
      list(call)
    }
  }

  transpiler <- function(expr, options = NULL) {
    ## Replace `%do%` with doFuture::`%dofuture%`
    expr[[1]] <- quote(doFuture::`%dofuture%`)
    call <- expr[[2]]
    fcn <- call[[1]]
    
    ## times()?
    if (identical(fcn, as.symbol("times")) ||
        identical(fcn, quote(foreach::times))) {
      ## Default to seed = TRUE
      defaults <- list(seed = TRUE, label = "fz:foreach::times-%d")
      options <- make_options_for_doFuture(options, defaults = defaults, wrap = FALSE)
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

      ## Assert that argument '.options.future' is not specified with %do%
      for (call in foreach_calls(expr[[2]])) {
        if (is.call(call) && !is.null(call[[".options.future"]])) {
          stop(sprintf("Cannot futurize foreach(..., .options.future = ...) %%do%% { ... }. Instead, pass future options to futurize(), e.g. futurize(seed = TRUE): %s", paste(deparse(call), collapse = " ")))
        }
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
