#import "styles.typ": style-defaults, style-state, frame, plain-env
#let shared-counter = counter("park-typst-shared-environment")
#let numbering-state = state("park-typst-numbering", (mode: "chapter", level: 1))
// Numbered boxes, equations, figures, tables and cross-page references. Calepin 0.0.61 / Typst 0.15.
#let chapter-state = state("stat-chapter-number", none)
#let kinds = ("Definition", "Theorem", "Lemma", "Proposition", "Corollary", "Example", "Algorithm", "Exercise", "Remark", "Note", "Claim", "Axiom", "Assumption")
#let kind-of(name) = "stat-" + name
#let chapter(number) = {
  assert(type(number) == int and number > 0, message: "chapter requires a positive integer.")
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    html.elem("span", attrs: ("data-stat-chapter": str(number), hidden: ""), [])
  }
  chapter-state.update(number)
  shared-counter.update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  for name in kinds { counter(figure.where(kind: kind-of(name))).update(0) }
}
#let box-parts(args, title: none) = {
  let parts = args.pos()
  assert(parts.len() == 1 or parts.len() == 2, message: "Use [body] or [title][body].")
  if parts.len() == 2 {
    assert(title == none, message: "Specify the title only once.")
    (title: parts.at(0), body: parts.at(1))
  } else { (title: title, body: parts.at(0)) }
}
#let number-at(it) = {
  let config = numbering-state.at(it.location())
  let is-box = it.func() == figure and type(it.kind) == str and it.kind.starts-with("stat-")
  if config.mode == "lecture" {
    let n = if is-box { shared-counter.at(it.location()).first() + 1 }
      else if it.func() == math.equation { counter(math.equation).at(it.location()).first() }
      else { counter(figure.where(kind: it.kind)).at(it.location()).first() }
    if is-box and config.level > 1 {
      let hs = counter(heading).at(it.location())
      let prefix = range(config.level - 1).map(i => hs.at(i, default: 0))
      numbering("1.1", ..prefix, n)
    } else { str(n) }
  } else {
    let ch = chapter-state.at(it.location())
    assert(ch != none, message: "Add #chapter(1) (or your chapter number) before the first box.")
    str(ch) + "." + str(if it.func() == math.equation { counter(math.equation).at(it.location()).first() }
      else { counter(figure.where(kind: it.kind)).at(it.location()).first() })
  }
}
// thmbox 0.2.0 appearance: no fill, 3pt left rule, right-aligned title.
#let box(kind, title: none, numbering: "1", ..args) = {
  let p = box-parts(args, title: title)
  figure([#if numbering != none { shared-counter.step() }#p.body], kind: kind-of(kind), supplement: kind, numbering: numbering,
    caption: if p.title == none { none } else { p.title }, placement: none,
    outlined: false)
}
#let colors = style-defaults.colors
#let definition = box.with("Definition")
#let theorem = box.with("Theorem")
#let lemma = box.with("Lemma")
#let proposition = box.with("Proposition")
#let corollary = box.with("Corollary")
#let example = box.with("Example")
#let algorithm = box.with("Algorithm")
#let exercise = box.with("Exercise")
#let remark = box.with("Remark", numbering: none)
#let note = box.with("Note")
#let claim = box.with("Claim", numbering: none)
#let axiom = box.with("Axiom")
#let assumption = box.with("Assumption")
#let proof(title: "Proof", separator: ".", body: [], ..args) = {
  let parts = args.pos()
  assert(parts.len() <= 2, message: "Use [body] or [title][body].")
  let heading = if parts.len() == 2 { [#title #parts.at(0)] } else { title }
  let body = if parts.len() > 0 { parts.last() } else { body }
  plain-env(heading, body, separator: separator, qed: true)
}
#let solution = proof.with(title: "Solution")
#let citep(key) = cite(key, form: "normal")
#let citet(key) = cite(key, form: "prose")
#let box-reference(it) = {
  it.kind.slice(5) + if it.numbering == none { "" } else { " " + number-at(it) }
}
#let native-reference(it) = {
  if it.func() == math.equation { "(" + number-at(it) + ")" }
  else if it.kind == table { "Table " + number-at(it) }
  else { "Figure " + number-at(it) }
}
#let is-native-reference(it) = {
  ((it.func() == math.equation and it.block and it.numbering != none) or
  (it.func() == figure and (it.kind == image or it.kind == table) and it.numbering != none))
}
#let native-html-anchor(it) = {
  if it.has("label") and is-native-reference(it) {
    html.elem("div", attrs: (
      id: "xref-" + str(it.label),
      "data-stat-label": str(it.label),
      "data-stat-ref": native-reference(it),
      style: "scroll-margin-top: 5rem;",
    ), it)
  } else { it }
}
#let crossrefs(body, index: (refs: (:), base_url: ""), url: path => path, mode: "chapter", counter-level: 1) = {
  assert(mode in ("chapter", "lecture"))
  numbering-state.update((mode: mode, level: counter-level))
  show heading: it => {
    if mode == "lecture" and counter-level > 1 and it.level == counter-level - 1 { shared-counter.update(0) }
    it
  }
  set math.equation(numbering: n => context {
    "(" + (if mode == "lecture" { str(n) } else { str(chapter-state.get()) + "." + str(n) }) + ")"
  })
  set figure(numbering: n => context {
    if mode == "lecture" { str(n) } else { str(chapter-state.get()) + "." + str(n) }
  })
  show math.equation.where(block: true): it => context {
    if target() == "html" { native-html-anchor(it) } else { it }
  }
  show figure: set block(breakable: true)
  show figure: it => context {
    if type(it.kind) == str and it.kind.starts-with("stat-") {
      let kind = it.kind.slice(5)
      let reference = box-reference(it)
      let title = if it.caption == none { none } else { it.caption.body }
      let id = if it.has("label") { str(it.label) } else { none }
      if kind == "Remark" {
        let heading = if title == none { [#reference] } else { [#reference #title] }
        plain-env(heading, it.body, id: id, reference: reference)
      } else {
        frame(reference, style-state.get().colors.at(kind), it.body, title: title, id: id, reference: reference)
      }
    } else if target() == "html" { native-html-anchor(it) } else { it }
  }
  show ref: it => context {
    let found = query(it.target)
    assert(found.len() <= 1, message: "Duplicate reference label: " + str(it.target))
    if found.len() > 0 {
      let el = found.first()
      if el.func() == figure and type(el.kind) == str and el.kind.starts-with("stat-") {
        let text = box-reference(el)
        if target() == "html" {
          link("#" + str(it.target), text)
        } else { link(el.location(), text) }
      } else if is-native-reference(el) {
        let text = native-reference(el)
        if target() == "html" {
          link("#xref-" + str(it.target), text)
        } else { link(el.location(), text) }
      } else { it }
    } else if index.at("scan_mode", default: false) {
      [Reference pending]
    } else {
      let name = str(it.target)
      let entry = index.refs.at(name, default: none)
      if entry != none {
        let path = entry.page + "#" + entry.anchor
        if target() == "html" {
          link(url("/" + path), entry.text)
        } else {
          link(index.base_url.trim("/", at: end) + "/" + path, entry.text)
        }
      } else {
        // Preserve normal Typst references/citations; unknown labels still fail.
        it
      }
    }
  }
  body
}
