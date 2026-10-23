// Package project preview. Consumer examples are in examples/.
#import "lib.typ": *
#show: lecture.with(
  title: "park-typst",
  subtitle: "Package preview",
  authors: ("Seoncheol Park",),
  lecturetype: "note",
)
= Package check
#definition[A root][A root satisfies $f(x) = 0$.] <def-root>
#theorem[A sample theorem][A sample statement.] <thm-demo>
#proof[A short proof.]
See @def-root and @thm-demo.
#remark[This package includes lecture, exam and code-display commands.]
Footnote test.#footnote[English footnote.]
