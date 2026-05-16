# multtest::MTP(..., cluster = 1) =>
#
# local({
#   library(parallel)
#   hack_env <- list(
#     clusterEvalQ = parallel::clusterEvalQ,
#     clusterApply = parallel::clusterApply,
#     clusterApplyLB = parallel::clusterApply,
#     stopCluster = function(cl) {
#       if (inherits(cl, "FutureCluster")) return(invisible(NULL))
#       parallel::stopCluster(cl)
#     }
#   )
#   attach(hack_env, name = "fz:multtest:bug_patch", pos = 2L, warn.conflicts = FALSE)
#   on.exit(detach("fz:multtest:bug_patch"))
#   cl <- future::makeClusterFuture(<future arguments>)
#   class(cl) <- c("SOCKcluster", class(cl))
#   oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
#   on.exit(options(oopts), add = TRUE)
#   multtest::MTP(..., cluster = cl)
# })
#
append_transpilers_for_multtest <- function() {
  if (getRversion() < "4.4.0") {
    stop(sprintf("You are running R %s, but futurization of 'multtest' functions requires R (>= 4.4.0)", getRversion()))
  }

  template_multtest <- bquote_compile(
    local({
      base_attach <- base::attach # silence R CMD check
      
      ## BUG FIX: 'multtest' does not import 'parallel' (or 'snow'), but
      ## rely on it to be one the search() path, possibly via a very
      ## old-school autoload().
      hack_env <- list(
        clusterEvalQ = parallel::clusterEvalQ,
        clusterApply = parallel::clusterApply,
        clusterApplyLB = parallel::clusterApply,
        stopCluster = function(cl) {
          if (inherits(cl, "FutureCluster")) return(invisible(NULL))
          parallel::stopCluster(cl)
        }
      )
      base_attach(hack_env, name = "fz:multtest:bug_patch", pos = 2L, warn.conflicts = FALSE)
      on.exit(detach("fz:multtest:bug_patch"), add = TRUE)
      
      cl <- do.call(.(CALL), args = .(OPTS))
      
      ## WORKAROUND: 'multtest' has a hardcoded assumption that the cluster
      ## class should inherit very old 'SOCKcluster' from the 'snow' package
      ## which is not neccessary.
      class(cl) <- c(class(cl), "SOCKcluster")
      
      oopts <- options(future.ClusterFuture.clusterEvalQ = "ignore")
      on.exit(options(oopts), add = TRUE)
      .(EXPR)
    })
  )

  transpilers <- make_package_transpilers("multtest", FUN = function(fcn, name) {
    if (name %in% c("MTP", "EBMTP")) {
      base_transpiler <- make_futurize_for_makeClusterFuture(
        template = template_multtest,
        args = list(
          cluster = quote(cl)
        ), defaults = list(
          label = sprintf("fz:multtest::%s", name),
          packages = "multtest",
          seed = TRUE
        )
      )

      transpiler <- eval(bquote(function(expr, options = NULL) {
        expr <- match.call(definition = .(fcn), call = expr)
        expr$cluster <- NULL
        expr$type <- NULL
        .(base_transpiler)(expr, options = options)
      }))

      list(
        label = sprintf("multtest::%s() ~> multtest::%s(..., cluster = cl)", name, name),
        transpiler = transpiler
      )
    }
  })

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("multtest", "future")
}
