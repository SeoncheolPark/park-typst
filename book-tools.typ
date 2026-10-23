#import "ref-blocks.typ": chapter-state, kinds, kind-of
#let default-config = (bibliography: none, style: "apa", references_title: "References", index: true, index_title: "Index")

// This marker exists in the combined document only, including Calepin's query pass.
#let is-book() = query(<stat-combined-book>).len() > 0

#let appendix(number) = {
  assert(type(number) == int and number > 0, message: "Use #appendix(1), #appendix(2), ...")
  let letter = numbering("A", number)
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("span", attrs: ("data-stat-chapter": letter, hidden: ""), [])
  }
  chapter-state.update(letter)
  counter(heading).update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  for name in kinds { counter(figure.where(kind: kind-of(name))).update(0) }
}

// Invisible marker. Repeat at each important occurrence.
#let index-entry(term, sort-key: none) = {
  assert(type(term) == str and term != "", message: "Index term must be a nonempty string.")
  [#metadata((term: term, sort: if sort-key == none { lower(term) } else { sort-key })) <stat-index-entry>]
}
#let indexed(term, body: none, sort-key: none) = {
  index-entry(term, sort-key: sort-key)
  if body == none { term } else { body }
}

// Apply AFTER #show: crossrefs in every chapter and appendix.
#let book-chapter(body, references: true, config: default-config, references-list: () => []) = context {
  // Preserve the requested standalone-note vs combined-book heading formats.
  if target() != "html" and sys.inputs.at("lecture-mode", default: "note") != "slide" {
    set heading(numbering: (..nums) => context {
      let ns = nums.pos()
      let ch = chapter-state.get()
      if type(ch) == str {
        if ns.len() == 1 { "Appendix " + ch }
        else { ch + "." + numbering("1.1", ..ns.slice(1)) }
      } else if is-book() {
        numbering("1.1", if ch == none { ns.first() } else { ch }, ..ns.slice(1))
      } else if ns.len() > 1 {
        numbering("1.1", ..ns.slice(1))
      }
    })
    body
  } else { body }
  if references and not is-book() and config.at("bibliography", default: none) != none {
    if query(cite).len() > 0 or query(ref).len() > 0 {
      // Level two starts a references slide; ordinary notes keep normal flow.
      heading(level: 2, numbering: none, config.at("references_title", default: "References"))
      references-list()
    }
  }
}

#let book-index() = context {
  let entries = query(<stat-index-entry>)
  let terms = entries.map(x => x.value.term).dedup()
  let terms = terms.sorted(key: term => entries.find(x => x.value.term == term).value.sort)
  columns(2, gutter: 10mm)[
    #for term in terms {
      let hits = entries.filter(x => x.value.term == term)
      let seen = ()
      let links = ()
      for hit in hits {
        let page = counter(page).at(hit.location()).first()
        if page not in seen {
          seen.push(page)
          links.push(link(hit.location(), str(page)))
        }
      }
      block(breakable: false, above: 0pt, below: .7em)[
        #term #h(.5em) #links.join([, ])
      ]
    }
  ]
}

#let book-backmatter(config: default-config, references-list: () => []) = context {
  if config.at("bibliography", default: none) != none {
    if target() != "html" { pagebreak(weak: true) }
    heading(level: 1, numbering: none, config.at("references_title", default: "References"))
    references-list()
  }
  if target() != "html" and config.at("index", default: true) and query(<stat-index-entry>).len() > 0 {
    pagebreak(weak: true)
    heading(level: 1, numbering: none, config.at("index_title", default: "Index"))
    book-index()
  }
}
