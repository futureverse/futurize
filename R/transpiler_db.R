.env <- new.env()
.env[["transpiler_db"]] <- list()

get_transpilers <- function(flavor) {
  .env[["transpiler_db"]][[flavor]]
}

append_transpilers <- function(flavor, ...) {
  transpiler_db <- .env[["transpiler_db"]]
  transpilers <- transpiler_db[[flavor]]
  transpilers <- c(transpilers, ...)
  transpiler_db[[flavor]] <- transpilers
  .env[["transpiler_db"]] <- transpiler_db
}


list_transpilers <- function() {
  data <- list()
  db <- .env[["transpiler_db"]]
  flavors <- names(db)
  for (flavor in flavors) {
    transpilers <- db[[flavor]]
    pkgs <- unique(names(transpilers))
    for (pkg in pkgs) {
      idxs <- which(pkg == names(transpilers))
      if (length(idxs) == 1) {
        transpilers_pkg <- transpilers[[idxs]]
      } else {
        ## length(idxs) > 1 should not happend, but in case ...
        transpilers_pkg <- list()
        for (idx in idxs) {
          transpilers_pkg <- c(transpilers_pkg, transpilers[[idx]])
        }
        drop <- duplicated(names(transpilers_pkg), fromLast = TRUE)
        transpilers_pkg <- transpilers_pkg[!drop]
      }
      transpilers_pkg <- transpilers_pkg[order(names(transpilers_pkg))]
      names <- names(transpilers_pkg)
      labels <- vapply(transpilers_pkg, FUN = function(t) t$label, FUN.VALUE = "")
      dd <- data.frame(flavor = flavor, package = pkg, fcn = names, description = labels)
      data <- c(data, list(dd))
    }
  }
  data <- Reduce(rbind, data)
  rownames(data) <- NULL
  data
}
