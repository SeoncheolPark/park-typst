#import "@local/park-typst:0.1.0": exams
#import exams: *
#show: exam.with(
  coursename: "Statistical Computing",
  assessment: "Code check",
  show-instruction: false,
)
#include-code-section(path("example.R"), "# BEGIN", "# END")
