#import "styles.typ": style-defaults, configure-style
#import "defaults.typ": note-defaults, slide-defaults

#let book-slides(body, settings: (:), slide-settings: (:), logo-render: (path, width, height) => image(path, width: width, height: height, fit: "contain")) = context {
  if target() == "html" { return body }
  let n = note-defaults + settings
  configure-style(settings: (font: n.font, mono-font: n.mono-font))
  let s = slide-defaults(n) + slide-settings
  let authors = if type(s.authors) == str { s.authors } else { s.authors.join(", ", last: " & ") }
  let logo(path, width, height) = box(width: width, height: height)[
    #if path != none { logo-render(path, width, height) }
  ]
  set document(author: authors)
  set text(font: n.font, size: s.font-size)
  set par(justify: false, leading: .5em)
  set heading(numbering: none)
  set page(
    width: s.width, height: s.height,
    margin: (x: s.margin-x, top: s.body-top, bottom: s.body-bottom),
    header: none, footer: none,
    // Background positions use the physical page, not the text margins.
    background: context {
      let current = here().page()
      let sections = query(<slide-section-marker>)
      let section = sections.rev().find(x => x.location().page() <= current)
      place(top + left)[
        #block(width: s.width, height: s.header-height, fill: s.header-fill,
          inset: (x: s.margin-x, y: 0pt))[
          #align(horizon)[
            #grid(columns: (1fr, s.small-logo-width), gutter: 3mm,
              align: (left + horizon, right + horizon),
              text(size: s.slide-title-size, weight: "bold", fill: n.accent)[
                #if section != none {
                  section.value
                  if section.location().page() < current { [ #s.continuation] }
                } else { n.title }
              ],
              logo(s.logo-small, s.small-logo-width, s.small-logo-height),
            )
          ]
        ]
      ]
      if s.footer {
        let total = counter(page).final().first()
        let ratio = current / total
        let titles = query(<slide-cover-marker>)
        let title = titles.rev().find(x => x.location().page() <= current)
        place(bottom + left, dx: s.margin-x, dy: -s.footer-bottom)[
          #block(width: s.width - 2 * s.margin-x)[
            #set par(spacing: 0pt, leading: 0pt)
            #set block(spacing: 0pt)
            #grid(columns: (ratio * 1fr, (1 - ratio) * 1fr),
              rect(width: 100%, height: 1.5pt, stroke: none, fill: n.accent.lighten(50%)),
              rect(width: 100%, height: 1.5pt, stroke: none, fill: n.accent.lighten(80%)),
            )
            #v(0.6mm)
            #grid(columns: (1fr, auto), gutter: 3mm,
              text(size: .7em, weight: "semibold", fill: n.accent)[
                #if title != none { title.value } else { n.title }
              ],
              text(size: .7em, weight: "semibold", fill: n.accent)[#current / #total],
            )
          ]
        ]
      }
    },
  )
  // Each level-one heading is a complete cover page, not an extra section
  // page after a separately generated cover.
  show heading.where(level: 1): it => {
    page(
      header: none, footer: none, background: none,
      margin: (x: s.margin-x, top: s.cover-top, bottom: 5mm),
    )[
      #metadata(it.body) <slide-cover-marker>
      #align(right)[#logo(s.logo, s.logo-width, s.logo-height)]
      #v(s.cover-title-gap)
      #block(width: 100%)[
        #text(s.title-size, weight: "bold", fill: n.accent, it.body)
        #if s.subtitle != none {
          block(above: 3mm)[#text(15pt, weight: "bold", fill: n.accent, s.subtitle)]
        }
      ]
      #v(0mm)
      #line(length: 100%, stroke: 2pt + n.accent.lighten(50%))
      #v(18mm)
      #set text(12pt, weight: "semibold")
      #authors
      #for item in (s.department, s.institution, s.date) {
        if item != none { block(above: 2mm, below: 0pt, item) }
      }
      #if s.email != none {
        block(above: 2mm)[#link("mailto:" + s.email, s.email)]
      }
      #v(1fr)
    ]
  }
  // The invisible marker is placed AFTER the break. Header lookup therefore
  // uses the correct page even at a boundary.
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    [#metadata(it.body) <slide-section-marker>]
  }
  show heading.where(level: 3): set text(
    size: s.subheading-size, weight: "bold", fill: n.accent,
  )
  show heading.where(level: 4): set text(
    size: 13pt, weight: "bold", fill: n.accent,
  )
  show raw: set text(font: n.mono-font, size: 9pt)
  // Calepin already styles block code; do not add another background.
  show raw.where(block: false): it => box(
    fill: n.accent.lighten(90%), inset: 1pt, radius: 1pt, it,
  )
  set list(marker: (
    text(fill: n.accent)[•],
    text(fill: n.accent)[‣],
    text(fill: n.accent)[-],
  ))
  set enum(numbering: nums => text(fill: n.accent, weight: "bold")[#nums.])
  show figure.caption: set align(left)
  show figure.where(kind: table): set block(breakable: true)
  show table.header: set text(weight: "bold")
  show link: it => highlight(
    fill: none, extent: 0pt,
    stroke: (paint: n.link-color, thickness: .6pt), it,
  )

  show footnote.entry: set text(
    font: style-defaults.footnote-font,
  )

  body
}
