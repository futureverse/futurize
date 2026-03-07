if (requireNamespace("glmmTMB") && getRversion() >= "4.4.0") {
library(futurize)
library(glmmTMB)
options(future.rng.onMisuse = "error")

plan(multisession)

## Adopted from example("confint.glmmTMB", package = "glmmTMB")
m <- glmmTMB(count ~ mined + (1 | site), data = Salamanders, family = nbinom2)

message("Ordinary processing:")
pr_truth <- profile(m)
print(head(pr_truth))

message("Futurized processing:")
pr <- profile(m) |> futurize()
print(head(pr))
message("Comparing results:")
stopifnot(all.equal(pr, pr_truth))


## confint.glmmTMB() via stats::confint() S3 generic dispatch
message("Ordinary processing:")
ci_truth <- confint(m, method = "profile")
print(ci_truth)

message("Futurized processing:")
ci <- confint(m, method = "profile") |> futurize()
print(ci)
message("Comparing results:")
stopifnot(all.equal(ci, ci_truth))

plan(sequential)
} ## if (requireNamespace("glmmTMB"))
