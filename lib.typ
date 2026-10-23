// Main interface for standalone notes, slides and exams.
#import "template.typ": *
#import "exam.typ" as exams
#import "exam.typ": exam
#import "rcode.typ" as rcode
// Calepin adapters use these namespaced interfaces.
#import "ref-blocks.typ" as refs
#import "book-tools.typ" as book
#import "blocks.typ" as plain-blocks
#import "modes.typ" as modes
#import "pdf-style.typ": book-pdf
#import "slide-style.typ": book-slides
#import "defaults.typ": note-defaults, slide-defaults
#import "styles.typ": style-defaults, configure-style
// Common authoring commands are also available directly from : *.
#import "exam.typ": question, mcq, section, ans, ansbank, blank, include-code-section, notice, nextpage, blankpage, bubble, docmode
#import "rcode.typ": *
#import "ref-blocks.typ": chapter
#import "book-tools.typ": appendix, index-entry, indexed
#import "book-document.typ": book-document
