#import "@local/park-typst:0.1.0": *
#show: lecture.with(
  lecturetype: "slide",
  title: "Newton's method",
  subtitle: "Statistical Computing",
  authors: ("Seoncheol Park",),
  firstlevelheading: false,
)
== Root finding
#definition[A root][A root satisfies $f(x)=0$.] <def-root>
See @def-root.
=== An iteration
$ x_(k+1) = x_k - frac(f(x_k), f'(x_k)) $
== Precomputed R code
#rcode.Skylighting(number: true, (
  [#rcode.NormalTok("x ")#rcode.OperatorTok("<-")#rcode.DecValTok(" 1")],
  [#rcode.FunctionTok("sqrt")#rcode.NormalTok("(2)")],
))
No R process is started by this package.
