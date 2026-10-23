// HTML always ignores PDF-only controls, even when a PDF mode input is set.
#let output-mode() = context {
  if target() == "html" { "web" } else { sys.inputs.at("lecture-mode", default: "note") }
}
#let slidebreak() = context {
  if target() != "html" and sys.inputs.at("lecture-mode", default: "note") == "slide" { pagebreak(weak: true) }
}
#let notebreak() = context {
  if target() != "html" and sys.inputs.at("lecture-mode", default: "note") == "note" { pagebreak(weak: true) }
}
#let slide-only(body) = context {
  if target() != "html" and sys.inputs.at("lecture-mode", default: "note") == "slide" { body }
}
#let note-only(body) = context {
  if target() != "html" and sys.inputs.at("lecture-mode", default: "note") == "note" { body }
}
#let web-only(body) = context { if target() == "html" { body } }

#let slide-columns(n, body) = context {
  if target() != "html" and (
    sys.inputs.at("lecture-mode", default: "note") == "slide"
  ) {
    columns(n, gutter: 8mm, body)
  } else {
    body
  }
}

#let slide-colbreak() = context {
  if target() != "html" and (
    sys.inputs.at("lecture-mode", default: "note") == "slide"
  ) {
    colbreak()
  }
}

#let note-columns(n, body) = context {
  if target() != "html" and (
    sys.inputs.at("lecture-mode", default: "note") == "note"
  ) {
    columns(n, gutter: 8mm, body)
  } else {
    body
  }
}

#let note-colbreak() = context {
  if target() != "html" and (
    sys.inputs.at("lecture-mode", default: "note") == "note"
  ) {
    colbreak()
  }
}