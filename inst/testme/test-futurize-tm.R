if (requireNamespace("tm") && getRversion() >= "4.4.0") {
library(futurize)
library(tm)
data(crude)

plan(multisession)


# -------------------------------------------------------------------------
# tm_map()
# -------------------------------------------------------------------------
## Use wrapper to apply character processing function
a0 <- tm_map(crude, content_transformer(tolower))
counters <- plan("backend")[["counters"]]
a1 <- tm_map(crude, content_transformer(tolower)) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(a0, a1), identical(a0, a1))

## Generate a custom transformation function which takes the heading as new content
headings <- function(x) {
  PlainTextDocument(meta(x, "heading"),
                    id = meta(x, "id"),
                    language = meta(x, "language"))
}                    
b0 <- tm_map(crude, headings)
counters <- plan("backend")[["counters"]]
b1 <- tm_map(crude, headings) |> futurize()
delta <- plan("backend")[["counters"]] - counters
cat(sprintf("Futures created: %d\n", delta[["created"]]))
stopifnot(delta[["created"]] > 0L)
stopifnot(all.equal(a0, a1), identical(a0, a1))


plan(sequential)
} ## if (requireNamespace("tm"))
