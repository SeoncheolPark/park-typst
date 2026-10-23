// Standalone book driver for the web app or CLI. No Calepin dependency.
#import "pdf-style.typ": book-pdf
#import "ref-blocks.typ": crossrefs
#import "book-tools.typ": book-chapter
#import "styles.typ": style-defaults
#let book-document(
  body,
  title: [],
  authors: (),
  toc: true,
  toc-depth: 2,
  settings: (:),
  backmatter: [],
) = {
  show: book-pdf.with(combined: true, settings: (title: title, authors: authors) + settings)
  show: crossrefs
  show: book-chapter.with(references: false)
  set document(title: title)
  [#metadata(true) <stat-combined-book>]
  if title != [] {
    page(header: none, footer: none)[
      #align(center + horizon)[
        #text(size: 30pt, weight: "bold", fill: style-defaults.accent, title)
        #v(16mm)
        #if type(authors) == str { authors } else { authors.join(", ", last: " & ") }
      ]
    ]
  }
  if toc {
    outline(depth: toc-depth)
    pagebreak(weak: true)
  }
  body
  backmatter
}
