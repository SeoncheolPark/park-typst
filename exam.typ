#import "styles.typ": style-defaults
// No logo assets are distributed. Pass a project-local path(...) if needed.
#let optional-logo(source, ..options) = {
  if source != none { image(source, ..options) }
}

#let section-counter = counter("sectioncounter")
#let section-points = state("sectionpoints", ())

#let q-counter = counter("question")
#let show-ansbox-state = state("show-ansbox", true)
#let question-prefix-state = state("question-prefix", "")
#let section-prefix-state = state("section-prefix", "")

/*#let add-points = p => {
  let current-section = section-counter.get().at(0)
  // 섹션이 시작되지 않았으면(0이면) 0번 인덱스를 사용하도록 조정
  let section = if cur
  rent-section > 0 { current-section - 1 } else { 0 }

  section-points.update(it => {
    // 배열의 길이를 현재 섹션 인덱스에 맞춰 확장
    for i in range(it.len(), section + 1) {
      it.push(0)
    }

    it.at(section) += p
    return it
  })
}*/
#let add-points = p => {
  section-points.update(it => {
    // 1. it이 배열이 아니거나 비어있으면 초기화
    let pts-array = if type(it) == array { it } else { () }
    
    // 2. 단순히 새로운 점수를 배열에 추가(push)합니다.
    pts-array.push(p)
    
    return pts-array
  })
}

#let notice(body) = block(
  width: 100%,
  inset: 10pt,
  radius: 4pt,
  fill: rgb("#f3f6fa"),
  stroke: 0.6pt + rgb("#9aa7b5"),
)[
  #text(
    weight: "bold",
    fill: rgb("#34495e"),
  )[Note.] #body
]

// q/a
#let colorblue = rgb("#2A40E2")

#let colorcyan = rgb("6993BF")
#let colorred = rgb("DD4466")
#let colorgreen = rgb("59B279")
#let colorgrey = rgb("808C80")

#let colorlightcyan = rgb("E8EDF4")
#let colorlightred = rgb("F4E8EC")
#let colorlightgreen = rgb("E8F4EC")
#let colorlightgrey = rgb("F6F6F6")


// print, screen, sol
// print will disable syntax highlighting for code blocks
#let docmode = state("mode", "sol")

// utils
#let hstack(..items) = {
  stack(dir: ltr, spacing: 0.75cm, ..items)
}

#let boxed(color: colorblue, body) = {
  align(center, rect(stroke: stroke(thickness:0.5pt,paint:color))[#body])
}

#let callout(t, body) = {
  let color = if t == "Definition" {
    colorcyan
  } else if t == "Formula" {
    colorred
  } else if t == "Method" {
    colorgreen
  } else if t == "Example" {
    colorgrey
  } else {
    rgb("000")
  }

  let bgcolor = if t == "Definition" {
    colorlightcyan
  } else if t == "Formula" {
    colorlightred
  } else if t == "Method" {
    colorlightgreen
  } else if t == "Example" {
    colorlightgrey
  } else {
    rgb("ebebeb")
  }

  block(
    fill: bgcolor,
    stroke: (left: stroke(thickness: 2.5pt, paint: color)),
    inset: (left: 10pt, right: 8pt, top: 8pt, bottom: 8pt),
    outset: (left: -2.5pt),
    radius: 0pt,
    width: 100%,
  )[
    #if t != "" [
      #text(t, fill: color, weight: 600)
      #v(-6pt)
    ]

    #body
  ]
}

#let info(body) = callout("", body)

#let subtitle(t) = [
  #v(6pt)
  #set text(size: 11.5pt, weight: 600)
  #show raw: set text(size: 9.5pt, weight: 600)

  #t
  #v(-6pt)
] 

#let pp = subtitle("Practice Problems")

#let section(title, height: auto, number: true, points: false, qrange: none, content) = {
  block(height: height)[
    #if number == true {
      section-counter.step()
      context {
        let current-idx = section-counter.get().at(0) - 1
        let pts-list = section-points.final()
        let pts = if current-idx < pts-list.len() { pts-list.at(current-idx) } else { 0 }
        let pstr = if pts == 1 { "point" } else { "points" }

        let prefix = section-prefix-state.get()

        let display-num = if qrange != none {
          if prefix == "" {
            [(#qrange) ]
          } else {
            [#prefix (#qrange) ]
          }
        } else {
          if prefix == "" {
            section-counter.display("1. ")
          } else {
            [#prefix #section-counter.display("1. ")]
          }
        }
        // qrange가 있으면 (1-2), 없으면 기존처럼 1. 출력
        /*let display-num = if qrange != none {
          "(" + qrange + ") "
        } else {
          section-counter.display("1. ")
        }*/

        let pts-text = if points { "[" + repr(pts) + " " + pstr + "] " } else { "" }

        if title != "" {
          text(strong(display-num) + pts-text + strong(title) , size: 10pt)
        }else{
          text(strong(display-num) + pts-text + title + content, size: 10pt)
        }
        
      }
    } else {
      if title != "" {
        text(title, size: 10pt)
      }else{
        text(title + content, size: 10pt)
      }
      
    }
    #if title != ""{
      v(-6pt)
      content
    }
  ]
}

#let ans(answer) = {
  context[
    #if docmode.get() == "sol" [
      #text(fill: colorblue)[#answer]
    ]
  ]
}


#let _getheight(height, ansheight, ansbox) = {
  // NOTE: must have context when run
  let h = if docmode.get() == "sol" { 
    if ansheight == -1 {
      if ansbox { 
        if height == auto { auto }
        else { height - 12pt }
      } else {
        auto
      }
    } else { 
      if ansheight == auto { auto }
      else { ansheight - 12pt }
    }
  } else {
    if height == auto { auto }
    else { height - 12pt }
  }

  return h
}

#let _getptstr(points) = {
  return if points == 1 { "pt" } else { "pts" }
}

// question()과 mcq()가 공통으로 사용하는 문제 헤더
// 번호, 점수, 문제 본문의 간격과 글꼴을 완전히 동일하게 유지
#let question-head(q-num, question, points: "") = context {
  let pstr = _getptstr(points)
  let prefix = question-prefix-state.get()

  text(
    (if prefix == "" { "" } else { prefix + " " })
      + repr(q-num) + ". ",
    weight: "bold",
  )

  if points != "" {
    text("(" + repr(points) + " " + pstr + ") ")
  }

  text(question)
}

// 3. question 함수: 전역 설정을 읽어서 출력하는 역할
#let question(
  question, 
  answer, 
  ansbox: false,
  gap: 0pt, // 박스가 숨겨졌을 때 추가할 간격 (기본값 0pt)
  show-ansbox: auto, // 기본값 auto
  points: "",
  ..args // 기타 height 등 인자들
) = {
  // 1. [중요] context 밖에서 점수를 먼저 업데이트합니다. (게시판에 쓰기)
  if points != "" {
    add-points(points)
  }
  q-counter.step()

  block(width: 100%)[
    #context {
      // exam에서 설정한 값을 가져옴
      let global-show = show-ansbox-state.get()
      
      // 개별 설정이 있으면 따르고, 없으면(auto) 전역 설정을 따름
      let final-show = if show-ansbox == auto { global-show } else { show-ansbox }
      let q-num = q-counter.get().at(0)

      // question()과 mcq()가 동일한 헤더를 사용
      question-head(q-num, question, points: points)

      v(-2pt)

      // 박스 출력 부분
      if final-show {
        // height 인자가 명시적으로 숫자로 들어오지 않았다면 'auto'를 사용하도록 합니다.
        let h = args.at("height", default: auto)
        
        // box는 가로로 흐르는 성질이 있어, block을 쓰는 것이 레이아웃 제어에 유리합니다.
        block(
          width: 100%, 
          stroke: if ansbox { 0.5pt } else { none }, 
          height: h,        // 여기가 auto이면 내용물에 맞춰 늘어납니다.
          inset: 7pt,
          radius: 2pt,      // 살짝 둥글게 하면 더 깔끔합니다.
          breakable: true    // 내용이 길어지면 다음 페이지로 넘어갈 수 있게 함
        )[
          #align(args.at("ansalign", default: horizon))[#ans(answer)]
        ]
      } else {
        v(gap)
      }

      // 최종 결정에 따라 박스 생성
      /*if final-show {
        let h = _getheight(
          args.at("height", default: auto), 
          args.at("ansheight", default: -1), 
          ansbox
        )
        box(width: 100%, stroke: if ansbox { 0.5pt } else { none }, height: h, inset: 7pt)[
          #align(args.at("ansalign", default: horizon))[#ans(answer)]
        ]
      }else{
        // 박스가 숨겨졌을 때만 사용자가 입력한 xpts(gap)만큼 띄움
        v(gap)
      }*/
    }
    // 박스가 있을 때의 하단 여백 유지
    #context {
      let global-show = show-ansbox-state.get()
      let raw-show = if show-ansbox == auto { global-show } else { show-ansbox }

      // [핵심] 어떤 타입이 들어오든 논리값으로 강제 치환
      let final-show = if type(raw-show) == bool {
        raw-show
      } else if raw-show == "true" or raw-show == "1" {
        true
      } else {
        false
      }
    }
  ]
}


#let mcq(
  question,
  choices,
  answer,
  cols: 1,
  multi: false,
  marker: "shape", // "shape" 또는 "circled"
  ansbox: false,
  height: auto,
  ansheight: auto,
  ansalign: horizon,
  color: colorblue,
  explanation: "",
  points: "",
) = {

  // 점수 합계에 반영
  // question()과 동일하게 context 밖에서 한 번만 실행
  if points != "" {
    add-points(points)
  }

  // 문제 번호 증가
  q-counter.step()

  // answer는 사용자가 보는 번호를 그대로 사용:
  // answer: 1 -> 첫 번째 보기
  // answer: 2 -> 두 번째 보기
  // answer: (1, 3) -> 첫 번째와 세 번째 보기
  let ansarr = if type(answer) == int {
    (answer,)
  } else {
    answer
  }

  let length = choices.len()
  let circled-numbers = (
    "①", "②", "③", "④", "⑤",
    "⑥", "⑦", "⑧", "⑨", "⑩",
    "⑪", "⑫", "⑬", "⑭", "⑮",
    "⑯", "⑰", "⑱", "⑲", "⑳",
  )

  context {
    let box-height = _getheight(height, ansheight, ansbox)

    let q-num = q-counter.get().at(0)
  
    // exam(sols: true/false)의 설정을 가져옴
    let global-show = show-ansbox-state.get()
  
    let show-solution = if type(global-show) == bool {
      global-show
    } else if global-show == "true" or global-show == "1" {
      true
    } else {
      false
    }

    // 각 보기 앞에 들어갈 원/네모 생성
    let items = range(length).map(i => [
      #let is-answer = ansarr.contains(i + 1)
    
      #if marker == "circled" {
        // ① ② ③ ④ 방식
        text(
          circled-numbers.at(i),
          fill: if show-solution and is-answer {
            color
          } else {
            black
          },
          weight: if show-solution and is-answer {
            "bold"
          } else {
            "regular"
          },
        )
      } else {
        // 기존 ○ / □ 방식
        let fill = if show-solution and is-answer {
          color
        } else {
          white
        }
    
        let strokecolor = if show-solution and is-answer {
          color
        } else {
          black
        }
    
        box(
          height: 7.5pt,
          width: 12pt,
          align(horizon)[
            #align(left)[
              #if multi {
                square(
                  size: 8.75pt,
                  stroke: stroke(
                    thickness: 0.5pt,
                    paint: strokecolor,
                  ),
                  fill: fill,
                )
              } else {
                circle(
                  radius: 4.75pt,
                  stroke: stroke(
                    thickness: 0.5pt,
                    paint: strokecolor,
                  ),
                  fill: fill,
                )
              }
            ]
          ],
        )
      }
    ])

    // enum의 번호 대신 위에서 만든 원/네모 사용
    set enum(
      numbering: (..nums, last) => [
        #items.at(last - 1)
      ],
    )

    let _cols = if type(cols) == array {
      cols
    } else {
      range(cols).map(_ => 1fr)
    }

    block(width: 100%)[
      // question()과 mcq()가 동일한 헤더를 사용
      #question-head(q-num, question, points: points)
      #v(-2pt)
      // ----------------------------
      // 보기
      // ----------------------------
      #grid(
        columns: _cols,
        row-gutter: 10pt,

        ..choices.enumerate().map(((i, c)) =>
          enum.item(i + 1)[#c]
        ),
      )
    ]

    // ----------------------------
    // 해설 / solution
    // sols: true일 때만 출력
    // ----------------------------
    if show-solution {
      if ansbox == true {
        box(
          width: 100%,
          stroke: stroke(
            thickness: 0.5pt,
            paint: black,
          ),
          height: box-height,
          inset: 7pt,
        )[
          #align(ansalign)[
            #text(fill: colorblue)[#explanation]
          ]
        ]
      } else if explanation != "" {
        box(
          width: 100%,
          stroke: none,
          height: box-height,
        )[
          #align(ansalign)[
            #text(fill: colorblue)[#explanation]
          ]
        ]
      }
    }
    
    v(8pt)
  }
}

#let ansbank(cols: 3, choices: ("",)) = [
  #box([
    #set enum(
      numbering: (..nums, last) => [
      #text(weight: "bold", numbering("A", last))
      #h(4pt)
    ]
    )

    #grid(columns: range(cols).map(_ => 1fr),
      row-gutter: 8pt, 

      ..choices.enumerate().map(((i, c)) =>
        enum.item(i + 1)[#c]
      )
    )], stroke: stroke(thickness: 0.5pt), inset: 6pt)
]

#let blank(width, placeholder, answer: none) = [
  #context[
    #box(width: width, stroke: (bottom: 0.5pt), outset: (y: 2pt, x: 1.5pt))[
      #align(center)[
        #text(
          baseline: -1.5pt,
          raw(if docmode.get() == "sol" and answer != none { answer } else { placeholder }))
      ]
    ]
  ]
]


#let nextpage(text: [See next page]) = {
  box(width: 100%)[
    #align(right)[#stack(dir: ltr, spacing: 5pt, smallcaps(text), [$arrow.r.long$])]
  ]
}

#let blankpage(text: [
  This page intentionally left blank

  The exam begins on the next page.
]) = {
  box(width: 100%, height: 95%)[
    #align(horizon)[#align(center)[
      #text
    ]]
  ]
}

#let bubble(content, color) = [
  #box(content, fill: color.mix(white).transparentize(65%), radius: 3pt, inset: 2.5pt, stroke: stroke(paint: color, thickness: 0.5pt), baseline: 2.5pt)
]

//typst에서 코드 읽는 함수 만듬
#let include-code-section(
  path,
  start-marker,
  end-marker,
  lang: "r",
) = {
  let code = read(path)

  let after-start = code.split(start-marker).at(1)
  let selected = after-start.split(end-marker).at(0).trim()

  raw(
    selected,
    block: true,
    lang: lang,
  )
}

#let exam(doc, 
  courseid: "",
  coursename: "",
  school: "",
  semester: "",
  instructor: "",
  assessment: "",
  labnum: "",
  labname: "",
  examdate: "",
  length: "",
  instructions: "",
  extra: [],
  sols: false,
  year: "",
  type: "",
  logo: none,
  logo-small: none,
  main-font: style-defaults.font,
  main-font-size: 24pt,
  show-instruction: true, // 안내 페이지 출력 여부
  show-studentinfo: true, //성명 출력 여부
  section-prefix: "",
  question-prefix: "", // 문제 번호 접두사
  ) = {
  // 입력받은 sols 값으로 박스 노출 여부를 전역 설정함
  show-ansbox-state.update(sols)
  section-prefix-state.update(section-prefix)
  question-prefix-state.update(question-prefix)
  // 1. 기본 문서 및 폰트 설정
  show footnote.entry: set text(font: style-defaults.footnote-font)
  set document(title: assessment + " " + coursename + " " + semester)
  set par(justify: true)
  set text(font: main-font, size: 10pt, lang: "ko")
  show smallcaps: set text(font: main-font)

  // custom raw for print
  // https://github.com/typst/typst/issues/1331
  set raw(lang: "python")  // all are default python

  show raw: set text(size: 8pt)

  show raw: it => context {
    if docmode.get() == "screen" or it.theme == none { return it }

    let fields = it.fields()
    let text = fields.remove("text")
    _ = fields.remove("lines")
    fields.at("theme") = none
    raw(..fields, text)
  }
  // 코드 블록 배경과 테두리
  show raw.where(block: true): code => block(
    width: 100%,
    inset: 8pt,
    radius: 4pt,
    fill: rgb("#f3f4f6"),
    stroke: 0.5pt + rgb("#d6d9dd"),
    breakable: true,
  )[
    #set text(
      font: style-defaults.mono-font,
      size: 8pt,
    )

    #raw(
      code.text,
      lang: code.lang,
      block: false,
    )
  ]

  // table styles
  show table.cell: set text(size: 9pt)
  show table.cell.where(y: 0): set text(size: 9pt, weight: 700)

  // enum styles, https://forum.typst.app/t/how-can-i-format-an-enums-numbering-without-overriding-the-numbering-style/3246
  set enum(
    full: true, 
    numbering: (..nums, last) => {
    text(
      weight: "bold", 
      numbering(("(a)","i.").at(nums.pos().len(), default: "1."), last)
    )
  }
  )

  set table(
    stroke: (x, y) => (
    left: if x == 0 { 0.5pt } else { 0pt },
    right: 0.5pt,
    top: if y <= 1 { 0.5pt } else { 0pt },
    bottom: 0.5pt,
  ),
    fill: (_, y) =>
    if calc.even(y) { luma(245) }
    else { white },
    inset: (x: 10pt, y: 5pt),
  )

  // format page (margins, set footer)
  /*set page(
    margin: (top: 1.65cm, bottom: 2.65cm, left: 1.65cm, right: 1.65cm),
    paper: "us-letter"
  )*/

  set page(
  margin: (
    left: 0.2in,
    right: 0.2in,
    top: 1.4in,
    bottom: 0.6in,
    ),
    paper: "a4",
  header: context {
      let is-odd = calc.odd(here().page())

      // 전체 문제의 총점 계산
      let pts-list = section-points.final()
      let total-pts = pts-list.fold(0, (acc, it) => acc + it)
      let total-pstr = _getptstr(total-pts)
      
      // text-part 정의
      let text-part = align(if is-odd { left } else { right })[
        #set text(weight: "bold")
        #text(size: main-font-size)[
          #if type == "종합시험" {
            [#assessment : #coursename, #year] 
          } else if type == "실습"{
            [#assessment #labnum: #labname]
          } else {
            [#assessment : #year #coursename #type]
          }
        ]\
        //#text(size: main-font-size)[#assessment : #year #coursename #type] \
        #if type== "실습"{
          v(-2pt)
          text(size: 10pt, weight: "regular")[#coursename (#courseid) — #semester]
          v(-6pt)
          text(size: 10pt, weight: "regular")[#instructor, #school — Total #total-pts points]
        } else {
          v(-2pt)
          text(size: 10pt, weight: "regular")[#examdate  — Total #total-pts points]; linebreak()
          v(-6pt)
          text(size: 10pt, weight: "regular")[#school]
        }
        /*#v(-2pt)
        #text(size: 10pt, weight: "regular")[#examdate]; #linebreak()
        #v(-6pt)
        #text(size: 10pt, weight: "regular")[#school]*/
        
      ]
      
      /*let logo-part = figure(optional-logo(logo, width: 220%, fit: "contain"))*/

      let logo-part = {
        stack(dir: ttb, spacing: 2pt)[
          #if sols == true {
            // 로고 위에 Solution 글씨 배치
            if is-odd{
              align(right)[
                #text(size: 18pt, weight: "bold", fill: red)[Solution]
                #v(-20pt)
              ]
            }else{
              align(left)[
                #text(size: 18pt, weight: "bold", fill: red)[Solution]
                #v(-20pt)
              ]
            }
            
          }
          #figure(optional-logo(logo, width: 220%, fit: "contain"))
          #v(-2pt)
        ]
      }
      box(height: 35pt)[
        #if is-odd {
          grid(columns: (4fr, 1fr), text-part, logo-part)
        } else {
          grid(columns: (1fr, 4fr), logo-part, text-part)
        }
        #v(-4pt)
        #line(length: 100%, stroke: 1pt)
      ]
    },
    footer: context {
      align(center)[
        #line(length: 100%, stroke: 0.5pt)
        #v(2pt)
        #text(size: 10pt)[#counter(page).display()]
      ]
    }
  )

  // 3. 안내 사항 페이지 (show-instruction이 true일 때만)
  if show-instruction==true {
    v(-20pt)
    smallcaps[#text("Instructions", size: 10pt, weight: "bold")]
    v(-6pt)

    if type == "실기시험"{
      [
        // --- 실습 시험용 안내문 (Alternative Version) ---
        -   You will have #length to finish this exam.
        // 총점을 자동으로 계산하여 출력
        #context {
          let pts-list = section-points.final()
  
          // 리스트의 모든 항목을 더합니다.
          let total-pts = pts-list.fold(0, (acc, it) => acc + it)
          [데이터 확인: #repr(pts-list)]
          [-   The exam is graded out of #total-pts points.]
        }
        - Students must use R or R Studio in *full-screen mode*.
        - Using Internet browsers is *not* allowed. Only accessing the course website #link("https://learning.hanyang.ac.kr") for uploading the final answers is allowed.
        - To prevent academic dishonesty, students *cannot* leave before the exam ends.
        - Late submissions within 10 minutes past the deadline will incur a *5-point deduction*, and submissions more than 10 minutes late will receive *0 points*.
        - We will give you *0 points* if over ten lines of your code are perfectly identical to other students.
        - If you do not follow these rules, we will give you 0 points for this exam.
        - In this exam, an *F grade will be given* if you use any LLM tools (e.g., Claude Code, ChatGPT, Google Gemini), messaging apps (e.g., KakaoTalk), or any unauthorized software.
        - Students should write (a single) R code about answers of exercises, submit it on course website.
        - If you have any questions, please raise your hand.  
        - Before leaving the classroom, please *check* whether your answers are uploaded well.
        - Students *must return* their exam papers after the test is finished.
      ]
    } else if type == "필기시험" or type == "" {
      [ 
        - *Don’t open this until you are told to do so*.
        - This is a closed-book exam.
        - You will have #length to finish this exam.
        // 총점을 자동으로 계산하여 출력
        #context {
          let pts-list = section-points.final()
  
          // 리스트의 모든 항목을 더합니다.
          let total-pts = pts-list.fold(0, (acc, it) => acc + it)
          //[데이터 확인: #repr(pts-list)]
          [-   The exam is graded out of #total-pts points.]
        }
        -  The weight for each question is listed in the left hand of each problem.     
        -  You should write down the answer in this sheet. //(반드시 이 종이에 답을 적으셔야 합니다. 연습용 종이에 적은 것은 점수로 인정되지 않습니다.)
        -  All answers should be written clearly and neatly.
        //-  In your proof, be clear about how each step follows from the preceding steps or form more basic results given in class.
      ]
    } else if type=="실습"{
      [
        - Students should write (a single) R code about answers of exercises, submit it on course website(#link("https://learning.hanyang.ac.kr/")).
        - Please *confirm that your answers have been uploaded successfully* to the course website.
        - Exercises labeled *with AI* are *mandatory*. You may use generative AI tools such as ChatGPT and discuss the problems with other students. However, you are responsible for checking and understanding everything you submit.
        - Exercises labeled *without AI* are *optional*. To receive credit, you must complete them independently, without using AI tools or discussing the problems with other students. You must write and run your code *in front of the instructor or a TA* within the specified time.
        - Generative AI tools and communication with other students are *not permitted during the midterm and final examinations*.
        - Submissions made within 5 minutes after the deadline will receive a *2-point deduction*. Submissions made more than 5 minutes after the deadline will receive *no credit*.
        - You may leave after submitting the mandatory *with AI* exercises. If you choose to attempt the optional *without AI* exercises for additional credit, you must complete the required in-person verification before leaving.
      ]
    }
    /*v(1em)
    align(center)[
      #table(
        columns: 7,
        inset: (x: 8pt, y: 5pt),
        fill: white,
        [Question], [1], [2], [3], [4], [5], [Total],
        [Points], [], [], [], [], [], []
      )
    ]*/

    if instructions != "" { instructions }

    v(-4pt)
    line(length: 100%, stroke: 0.75pt)
    
    if extra != "" { extra }

    if show-studentinfo == true {
      // 수험생 정보 입력란
      set par(justify: false)
      set text(top-edge: 80pt)
      let blanks = ("Your Student ID", "Your Name")
      for x in blanks [
        #v(20pt)
        #smallcaps[Print] #x: #box(width: 1fr)[#line(stroke: 0.45pt, length: 100%)]
      ]
      /*v(30pt)
      line(length: 100%, stroke: 0.75pt)*/
    }
    if type != "실습"{
      colbreak()
      // 4. 본문 출력 (항상 헤더 쪽으로 10pt 끌어올림)
      v(-20pt)
    }
  }

  
  doc

}

