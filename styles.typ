// Shared typography and environment appearance for books, notes, slides and exams.
#let style-defaults = (
  font: ("IBM Plex Sans", "IBM Plex Sans KR", "Noto Sans", "DejaVu Sans"),
  mono-font: ("Monoplex KR", "IBM Plex Mono", "DejaVu Sans Mono"),
  footnote-font: ("IBM Plex Serif", "Noto Serif KR"),
  accent: rgb("#0E4A84"),
  link-color: rgb("#3fa1d2"),
  box-border: 3pt,
  box-title-gap: 1.2em,
  colors: (
    Definition: "#ff851b", Theorem: "#C5283D", Lemma: "#90c6b7",
    Proposition: "#5f83d2", Corollary: "#c34dd1", Example: "#8dc159",
    Algorithm: "#66118d", Exercise: "#68b3ff", Remark: "#797979", Note: "#118d8d",
    Claim: "#4a9952", Axiom: "#3fa1d2", Assumption: "#575757",
  ),
)
#let style-state = state("park-typst-style", style-defaults)
#let configure-style(settings: (:)) = style-state.update(style-defaults + settings)

#let frame(label, color, body, title: none, id: none, reference: none) = context {
  let s = style-state.get()
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    let attrs = (class: "stat-box", style: "background:transparent;border:0;border-radius:0;border-left:" + repr(s.box-border) + " solid " + color + ";padding:0.6em 0 0.6em 1em;margin:1.2em 0;scroll-margin-top:5rem;")
    if id != none {
      attrs.insert("id", id)
      attrs.insert("data-stat-ref", reference)
    }
    html.elem("aside", attrs: attrs)[
      #html.elem("div", attrs: (style: "display:flex;justify-content:space-between;gap:1em;flex-wrap:wrap;font-weight:700;color:" + color + ";margin-bottom:" + repr(s.box-title-gap) + ";"))[
        #html.elem("span", label)
        #if title != none { html.elem("span", attrs: (style: "margin-left:auto;text-align:right;"), title) }
      ]
      #html.elem("div", attrs: (style: "padding-right:1em;"), body)
    ]
  } else {
    set align(left)
    set text(font: s.font)
    block(width: 100%, breakable: true,
      inset: (left: 1em, right: 0em, top: 0.6em, bottom: 0.6em),
      spacing: 1.2em, fill: none, stroke: (left: s.box-border + rgb(color)))[
      #block(above: 0em, below: s.box-title-gap)[
        #set text(weight: "bold", fill: rgb(color))
        #label #h(1fr) #if title != none { title }
      ]
      #block(inset: (right: 1em), spacing: 0em, width: 100%, body)
    ]
  }
}
#let plain-env(title, body, separator: ".", qed: false, id: none, reference: none) = context {
  if sys.inputs.at("calepin-target", default: "paged") == "html" {
    let attrs = (style: "margin:1em 0;background:transparent;border:0;padding:0;color:inherit;scroll-margin-top:5rem;")
    if id != none {
      attrs.insert("id", id)
      attrs.insert("data-stat-ref", reference)
    }
    html.elem("div", attrs: attrs)[
      #html.elem("span", attrs: (style: "font-style:oblique;font-weight:400;margin-right:0.3em;"))[#title#separator]
      #body
      #if qed {
        html.elem("div", attrs: (style: "text-align:right;", "aria-label": "End of proof"), [□])
      }
    ]
  } else {
    set align(left)
    block(width: 100%, breakable: true, inset: 0pt, fill: none, stroke: none)[
      #text(style: "oblique", weight: "regular")[#title#separator]
      #h(0.3em)#body
      #if qed { [#h(1fr)#context text(size: 0.8 * text.size)[□]] }
    ]
  }
}
