# mlr3::resample(...) =>
#
# local({
#   ## This will be automatically consumed and removed by 'future.apply'
#   options(future.disposable = structure(<future options>, dispose = FALSE))
#   ## Make sure 'mlr3' parallelizes via futures, even if mirai daemons
#   ## have been set up for the 'mlr3' compute profile
#   ...future_oopts <- options(mlr3.mirai_parallelization = ".futurize-no-mirai")
#   on.exit({
#     options(...future_oopts)
#     options(future.disposable = NULL)
#   })
#   mlr3::resample(...)
# })
#
# Ditto for mlr3::benchmark(...).
#
# If argument 'rewrite' of make_futurize_for_mlr3() is given, then the
# call may be rewritten, and a prologue be injected before it, e.g. to
# validate arguments at run time. This is used by addons-mlr3tuning.R.
#
# Note that 'mlr3' calls future.apply::future_mapply() itself, with
# carefully chosen 'future.*' arguments, e.g. future.seed = TRUE,
# future.globals = FALSE, and future.packages = <packages loaded by mlr3>.
# Since 'future.disposable' options override those arguments, we only
# pass on the future options that were explicitly specified in the
# futurize() call, plus a future label. Options 'globals' and 'packages'
# are never passed on, because 'mlr3' manages those itself.
#
make_futurize_for_mlr3 <- local({
  templates <- NULL

  function(defaults, rewrite = NULL) {
    ## Avoid lazy evaluation, because these arguments may be promises
    ## to loop variables, e.g. in make_package_transpilers()
    force(defaults)
    force(rewrite)

    if (is.null(templates)) {
      templates <<- list(
        plain = bquote_compile(
         local({
            ## This will be automatically consumed and removed by 'future.apply'
            options(future.disposable = structure(.(OPTS), dispose = FALSE))
            ## Make sure 'mlr3' parallelizes via futures, even if mirai daemons
            ## have been set up for the 'mlr3' compute profile
            ...future_oopts <- options(mlr3.mirai_parallelization = ".futurize-no-mirai")
            on.exit({
              options(...future_oopts)
              options(future.disposable = NULL)
            })
            .(EXPR)
          })
        ),
        prologue = bquote_compile(
         local({
            ## This will be automatically consumed and removed by 'future.apply'
            options(future.disposable = structure(.(OPTS), dispose = FALSE))
            ## Make sure 'mlr3' parallelizes via futures, even if mirai daemons
            ## have been set up for the 'mlr3' compute profile
            ...future_oopts <- options(mlr3.mirai_parallelization = ".futurize-no-mirai")
            on.exit({
              options(...future_oopts)
              options(future.disposable = NULL)
            })
            .(PROLOGUE)
            .(EXPR)
          })
        )
      )
    }

    function(expr, options = NULL) {
      specified <- attr(options, "specified")
      specified <- sub("^chunk_size$", "chunk.size", specified)
      specified <- setdiff(specified, c("globals", "packages"))
      keep <- c(names(defaults), sprintf("future.%s", specified))

      opts <- make_options_for_future.apply(options, defaults = defaults, fcn = future.apply::future_mapply)
      opts <- opts[intersect(names(opts), keep)]
      names(opts) <- sub("^future[.]", "", names(opts))

      prologue <- NULL
      if (!is.null(rewrite)) {
        res <- rewrite(expr)
        expr <- res[["expr"]]
        prologue <- res[["prologue"]]
      }

      if (is.null(prologue)) {
        bquote_apply(templates[["plain"]],
          OPTS = opts,
          EXPR = expr
        )
      } else {
        bquote_apply(templates[["prologue"]],
          OPTS = opts,
          PROLOGUE = prologue,
          EXPR = expr
        )
      }
    }
  }
}) ## make_futurize_for_mlr3()


append_transpilers_for_mlr3 <- function() {
  transpilers <- make_package_transpilers("mlr3", FUN = function(fcn, name) {
    if (name %in% c("benchmark", "resample")) {
      defaults <- list(
        future.label = sprintf("fz:mlr3::%s-%%d", name)
      )
      list(
        label = sprintf("mlr3::%s() ~> mlr3::%s()", name, name),
        transpiler = make_futurize_for_mlr3(defaults = defaults)
      )
    }
  }, s3methods = FALSE)

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("mlr3", "future.apply")
}
