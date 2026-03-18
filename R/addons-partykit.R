# partykit::cforest(...) =>
#
# partykit::cforest(..., applyfun = function(...) {
#   future.apply::future_lapply(..., future.seed = TRUE)
# })
#
append_transpilers_for_partykit <- function() {
  transpilers <- make_package_transpilers("partykit", FUN = function(fcn, name) {
    if ("applyfun" %in% names(formals(fcn))) {
      list(
        label = sprintf("partykit::%s() ~> partykit::%s()", name, name),
        transpiler = make_futurize_for_future.apply(
          defaults = list(
            future.seed = TRUE
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
  c("partykit", "future.apply")
}
