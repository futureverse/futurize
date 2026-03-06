# mice::mice(...) =>
#
# mice::futuremice(..., future.plan = ...)
#
append_transpilers_for_mice <- function() {
  template <- bquote_compile(
   local({
      old_plan <- plan("next")
      on.exit(plan(old_plan))
      .(EXPR)
    })
  )

  transpiler <- function(expr, options = NULL) {
    expr <- append_call_arguments(expr,
      future.plan = quote(old_plan),
      globals = options[["globals"]],
      packages = options[["packages"]]
    )
    
    bquote_apply(template,
      EXPR = expr
    )
  }

  transpilers <- make_package_transpilers("mice", FUN = function(fcn, name) {
    if (name %in% "mice") {
      list(
        label = sprintf("mice::%s() ~> mice::future%s(..., future.plan = ...)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("mice", "future.apply")
}
