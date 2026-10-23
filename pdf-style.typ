#import "styles.typ": style-defaults, configure-style
#import "defaults.typ": note-defaults
#import "ref-blocks.typ": chapter-state

// Only paged A4 notes use this style; HTML and slide styles stay separate.
#let book-pdf(body, combined: false, settings: (:), logo-render: (path, width, height) => image(path, width: width, height: height, fit: "contain")) = context {
  if target() == "html" { return body }
  let s = note-defaults + settings
  configure-style(settings: (font: s.font, mono-font: s.mono-font))
  let authors = if type(s.authors) == str { s.authors } else { s.authors.join(", ", last: " & ") }
  set document(author: authors)
  set text(font: s.font, size: 11pt)
  set page(
    paper: "a4",
    margin: (top: 28mm, bottom: 28mm, x: 14mm),
    header: context {
      grid(
        columns: (1fr, s.logo-width), gutter: 5mm,
        align: (left + horizon, right + horizon),
        text(11.5pt, weight: "bold", s.title),
        box(width: s.logo-width, height: s.logo-height)[
          #if s.logo != none {
            logo-render(s.logo, s.logo-width, s.logo-height)
          }
        ],
      )
    },
    footer: context [
      #text(11.5pt, weight: "bold", authors)
      #h(1fr)
      #text(11.5pt, weight: "bold", counter(page).display("1"))
    ],
  )
  set par(justify: false, leading: .65em)
  // The explicit #chapter(n) determines the first component, including
  // a standalone chapter 2 PDF. Lower levels use Typst's heading counter.
  /*set heading(numbering: (..nums) => context {
    let values = nums.pos()
    let ch = chapter-state.get()
    let first = if ch == none { values.first() } else { ch }
    numbering("1.1", first, ..values.slice(1))
  })*/
  // 개별 note만 큰 제목의 번호를 숨김
  show heading.where(level: 1): it => {
    if combined {
      it
    } else {
      set heading(numbering: none)
      it
    }
  }

  // note와 book의 번호 체계를 구분
  set heading(numbering: (..nums) => context {
    let values = nums.pos()

    if combined {
      // book: 1 → 1.1 → 1.1.1
      let ch = chapter-state.get()
      let first = if ch == none { values.first() } else { ch }
      numbering("1.1", first, ..values.slice(1))
    } else if values.len() > 1 {
      // note: 큰 제목은 무번호, 그 아래부터 1 → 1.1
      numbering("1.1", ..values.slice(1))
    }
  })
  show heading.where(level: 1): it => {
    block(width: 100%, above: 0pt, below: 1.4em)[
      #align(center)[#text(19.5pt, weight: "bold", it)]
      #if not combined {
        block(above: .5em, below: 0pt, width: 100%)[
          #align(center)[#text(11pt, weight: "regular", authors)]
        ]
      }
    ]
  }
  show heading.where(level: 2): set text(size: 14pt, weight: "bold", fill: s.accent)
  show heading.where(level: 3): set text(size: 11.5pt, weight: "bold", fill: s.accent)
  show raw: set text(font: s.mono-font, size: 9pt)
  show figure.caption: set align(left)
  show figure.where(kind: table): set block(breakable: true)
  // Decorate the actual links produced by crossrefs, without replacing
  // its label lookup or equation/theorem numbering.
  show link: it => highlight(
    fill: none, extent: 0pt,
    stroke: (paint: s.link-color, thickness: .6pt),
    it,
  )

  show footnote.entry: set text(
    font: style-defaults.footnote-font,
  )

  body
}
