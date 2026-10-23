#import "styles.typ": style-state, frame, plain-env
#import "ref-blocks.typ": box-parts, proof, solution, citep, citet
#let box(kind, title: none, ..args) = context {
  let p = box-parts(args, title: title)
  frame(kind, style-state.get().colors.at(kind), p.body, title: p.title)
}
#let definition = box.with("Definition")
#let theorem = box.with("Theorem")
#let lemma = box.with("Lemma")
#let proposition = box.with("Proposition")
#let corollary = box.with("Corollary")
#let example = box.with("Example")
#let algorithm = box.with("Algorithm")
#let exercise = box.with("Exercise")
#let note = box.with("Note")
#let claim = box.with("Claim")
#let axiom = box.with("Axiom")
#let assumption = box.with("Assumption")
#let remark(title: none, ..args) = {
  let p = box-parts(args, title: title)
  plain-env(if p.title == none { [Remark] } else { [Remark #p.title] }, p.body)
}
