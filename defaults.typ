#import "styles.typ": style-defaults
// Change these values when sharing the note template with colleagues.
#let note-defaults = (
  title: "Lecture",
  authors: (),
  logo: none, // none hides the logo
  logo-small: none,
  logo-width: 32mm,
  logo-height: 10mm,
  font: style-defaults.font,
  mono-font: style-defaults.mono-font,
  accent: style-defaults.accent,
  link-color: style-defaults.link-color,
)

// Shared name, fonts and color come from note-settings; overrides go here.
#let slide-defaults(note-settings) = (
  subtitle: note-settings.title,
  authors: note-settings.authors,
  department: none,
  institution: none,
  email: none,
  date: none,
  logo: note-settings.logo,
  logo-small: note-settings.logo-small,
  logo-width: 36mm,
  logo-height: 10mm,
  small-logo-width: 7mm,
  small-logo-height: 7mm,
  width: 186.6667mm,
  height: 105mm,
  margin-x: 8mm,
  body-top: 13mm,
  body-bottom: 7mm,
  header-height: 10mm,
  footer-bottom: 1mm,
  cover-top: 3mm,
  cover-title-gap: 0mm,
  font-size: 11pt,
  title-size: 28pt,
  slide-title-size: 22pt,
  subheading-size: 16.5pt,
  header-fill: rgb("#898C8E").lighten(75%),
  continuation: "(cont.)",
  footer: true,
)
