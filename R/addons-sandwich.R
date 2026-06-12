# sandwich::vcovBS(...) =>
#
# sandwich::vcovBS(..., applyfun = function(...) {
#   future.apply::future_lapply(..., future.seed = TRUE)
# })
#
append_transpilers_for_sandwich <- function() {
  transpilers <- make_package_transpilers("sandwich", FUN = function(fcn, name) {
    if ("applyfun" %in% names(formals(fcn)) || name %in% c("vcovBS", "vcovJK")) {
      list(
        label = sprintf("sandwich::%s() ~> sandwich::%s()", name, name),
        transpiler = make_futurize_for_future.apply(
          defaults = list(
            future.seed = TRUE,
            future.label = sprintf("fz:sandwich::%s-%%d", name)
          ),
          args = list(
            applyfun = function(...) {
              future.apply::future_lapply(...)
            }
          )
        ) ## make_futurize_for_future.apply()
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("sandwich", "future.apply")
}
