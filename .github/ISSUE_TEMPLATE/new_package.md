---
name: Add futurize() support for package
about: Suggest an R package that could benefit from futurize()
title: ''
labels: 'candidate package'
assignees: ''

---
(Please use <https://github.com/futureverse/discussions> for Q&A)

**Feature request**

Do you know of a CRAN or Bioconductor package that currently support
parallelization, but is a bit tedious to set up and configure? Would
it be easier if one could let `futurize()` take care of everything for
us? If so, it might be a candidate for the **futurize** package.

**Package**

Please provide the link to the package on CRAN or Bioconductor. Please also provide a link to their source code, e.g. a GitHub repository.

**Example**

It is essential that the candidate package allows us to control how parallelization is executed. For example, we might be able to register a **foreach** `%dopar%` adaptor, or pass an custom parallel cluster via an
argument. If the package hardcodes the parallelization backend
internally, then it is unlikely a candidate for `futurize()`. If that
is the case, please reach out to the package maintainer to discuss if
they make adjustments for external controls.

Please provide an minimal reproducible example on how the package
currently supports parallelization of one or more of its functions.


Please format your inline code and code blocks using Markdown (<https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax>).

