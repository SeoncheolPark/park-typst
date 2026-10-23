#import "@local/park-typst:0.1.0": *
#show: lecture.with(
  lecturetype: "note",
  title: "Newton's method",
  authors: ("Seoncheol Park",),
)
= Root finding
#definition[A root][A root satisfies $f(x)=0$.] <def-root>
#theorem[Convergence][Assume sufficient regularity.] <thm-demo>
#proof[A short proof.]
#remark[Use a suitable stopping criterion.]
See @def-root and @thm-demo.
$ x_(k+1) = x_k - frac(f(x_k), f'(x_k)) $ <eq-newton>
See @eq-newton. Footnote test.#footnote[English footnote.]
#code("x <- 1\nx <- x - (x^2 - 2) / (2*x)", lang: "r")
