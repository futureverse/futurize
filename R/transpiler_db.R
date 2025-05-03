.env <- new.env()
.env[["transpiler_db"]] <- list()

get_transpilers <- function(flavor) {
  .env[["transpiler_db"]][[flavor]]
}

append_transpilers <- function(flavor, ...) {
  transpiler_db <- .env[["transpiler_db"]]
  transpiler_db[[flavor]] <- c(transpiler_db[[flavor]], ...)
  .env[["transpiler_db"]] <- transpiler_db
}
