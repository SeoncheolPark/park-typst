# park-typst 0.1.0

책·강의노트·슬라이드·시험지에 사용하는 공통 Typst 패키지입니다.
기존 park-lecture(책)와 park-typstweb(독립 문서)의 기능을 한 패키지로 통합했습니다.
학교 로고, references.bib, 폰트, R/Python 실행기는 포함하지 않습니다.

## 가장 먼저 할 일: 웹 앱에서 새 패키지 테스트

1. 이 폴더의 내용을 GitHub의 새 park-typst 저장소에 올립니다.
   typst.toml과 lib.typ가 저장소 최상위에 있어야 합니다.
2. Typst Pro 웹 앱에서 Start from GitHub로 이 저장소를 가져옵니다.
   또는 Empty project를 만든 뒤 ZIP을 압축 해제한 파일들을 올립니다.
3. preview.typ를 미리보기 대상으로 선택합니다.
4. typst.toml을 열고 park-typst / 0.1.0 / lib.typ를 확인한 뒤 Publish합니다.
5. 다른 빈 프로젝트에서 아래 예제를 테스트합니다.

기존 park-typstweb/park-lecture는 그대로 두고 새 이름으로 테스트할 수 있습니다.
아직 자동으로 기존 강의 원고의 import를 바꾸지는 않습니다.

```typst
#import "@local/park-typst:0.1.0": *
#show: lecture.with(
  lecturetype: "note",
  title: "확률론",
  authors: ("Seoncheol Park",),
)
= 확률공간
#definition[확률공간][여기에 정의를 씁니다.] <def-space>
#theorem[예시 정리][여기에 명제를 씁니다.] <thm-demo>
#proof[여기에 증명을 씁니다.]
See @def-space and @thm-demo.
```

## 무엇이 하나가 되었나요?

- GitHub 원본 저장소와 앱의 Private Package: park-typst 하나
- 정리·정의·증명·remark의 렌더링: styles.typ와 ref-blocks.typ 한 벌
- 본문/코드/각주 글꼴과 기본 색상: styles.typ 한 곳
- 코드 구문 강조와 Skylighting 표시: rcode.typ 한 벌
- 시험지 기능: 같은 패키지의 exam.typ

문서 목적에 따라 여백·머리말·제목 구조는 다릅니다.
기존 앱용 lecture 레이아웃과 Calepin 책 레이아웃은 각각의 드라이버에서 유지합니다.
패키지가 하나라는 것이 모든 문서를 똑같은 용지/번호/여백으로 만든다는 뜻은 아닙니다.

## 문서 종류별 시작 방법

### 독립 강의노트

```typst
#import "@local/park-typst:0.1.0": *
#show: lecture.with(lecturetype: "note", title: "회귀분석", authors: "Seoncheol Park")
= Linear regression
본문
```

### 독립 슬라이드

```typst
#import "@local/park-typst:0.1.0": *
#show: lecture.with(
  lecturetype: "slide",
  title: "Regression analysis",
  authors: "Seoncheol Park",
  firstlevelheading: false,
)
== Introduction
본문
=== A subheading
본문
== The next slide
본문
```

title 옵션으로 표지가 자동 생성되고, ==에서 슬라이드가 바뀝니다.
Calepin 슬라이드의 '=이 표지' 규칙과는 다릅니다. 각 기존 동작을 유지했습니다.
slidebreak()/notebreak(), slide-columns()/note-columns() 등도 제공합니다.

### 시험지

```typst
#import "@local/park-typst:0.1.0": *
#show: exam.with(
  coursename: "전산통계",
  assessment: "중간고사",
  year: "2026",
  school: "Hanyang University",
  sols: false,
  show-instruction: false,
)
#section("Questions")[
  #question([Compute $1+1$.], [2], points: 2)
]
```

question, mcq, section, ansbank, blank, include-code-section도 바로 사용할 수 있습니다.
기존처럼 exams 모듈을 별도로 import하는 방식 역시 유지했습니다.

### 웹 앱/CLI에서 합본 책 만들기 (Calepin 없이)

```typst
#import "@local/park-typst:0.1.0": *
#show: book-document.with(title: "확률론", authors: "Seoncheol Park")
#chapter(1)
= 확률공간
#definition[정의][본문] <def-space>
#pagebreak()
#chapter(2)
= 확률변수
앞장의 @def-space 를 참고합니다.
```

실제로는 #include "chapters/01.typ" 등으로 내용 파일을 모을 수 있습니다.
내용 파일에는 #chapter(n), 제목, 본문을 두고, 각각 별도의 lecture show를 적용하지 않습니다.
references.bib는 원고 프로젝트에 두고 #bibliography("references.bib", style: "apa")로 출력합니다.
부록은 #appendix(1), 색인은 #index-entry("term")로 표시한 뒤 필요 위치에서
#heading(numbering: none)[Index]와 #book.book-index()를 호출할 수 있습니다.
실제 장 사이의 페이지 나누기는 #pagebreak()로 지정합니다.
examples/book.typ가 작동 예제입니다.

Calepin으로 책과 사이트를 만들 때는 기존 build.sh/build_book.py를 사용합니다.
아래의 Calepin 전환 방법을 참고하세요.

## 번호 체계

- 독립 lecture: Definition 1, Theorem 2 등 공유 연속 번호
- lecture.with(counter-level: 2): Definition 1.1, Theorem 1.2 등 절별 공유 번호
- 책: Definition 1.1, Theorem 1.1 등 장별/종류별 번호
- proof/remark/claim: 기본 무번호

각 문서 종류의 기존 번호 체계를 유지하면서 박스의 디자인 구현은 공유합니다.

## 어디를 수정하나요?

| 파일 | 수정 내용 |
|---|---|
| styles.typ | 공통 글꼴·각주·색상·정리 박스·proof/remark 디자인 |
| template.typ | 독립 note/slide/note-horiz 레이아웃 |
| pdf-style.typ | Calepin note 및 책의 레이아웃 |
| slide-style.typ | Calepin 슬라이드의 레이아웃 |
| defaults.typ | 책/Calepin 드라이버의 기본 크기·여백 설정 |
| exam.typ | 시험지 배치와 문제/해설 기능 |
| rcode.typ | 코드 토큰 색상과 줄 배치 |
| ref-blocks.typ | 정리·수식·그림·표 번호 및 참조 처리 |
| book-tools.typ | 부록·색인·참고문헌 배치 기능 |
| book-document.typ | 독립 합본 책의 표지·목차·공통 규칙 적용 |

예를 들어 styles.typ의 box-border: 3pt를 5pt로 바꾸면
책과 독립 강의자료의 정리 박스 선 두께가 함께 바뀝니다.
colors의 Theorem 색상을 바꾸면 두 환경의 정리 색상이 함께 바뀝니다.
독립 문서와 책의 PDF 각주는 footnote-font를 같이 사용합니다.

원고에서 main-font, title-font 또는 교재의 note-settings.typ에 font를 지정하면
그 문서의 설정이 공통 기본값보다 우선합니다.
HTML 본문의 글꼴과 사이트 메뉴 색상은 Calepin의 CSS에서 설정합니다.
HTML 정리 박스 구조/색상은 이 패키지의 공통 렌더러를 사용합니다.

## 로고와 참고문헌

기본 logo/logo-small은 none이며 이미지 파일은 배포하지 않습니다.
개별 프로젝트의 이미지가 필요하면 원고에서 경로 객체로 전달합니다.

```typst
logo: path("/images/hanyang.png"),
logo-small: path("/images/hanyang_mini.png"),
```

문자열만 넘기면 패키지 내부 경로로 해석될 수 있으므로 path(...)를 사용합니다.
R 코드 읽기도 #include-code-section(path("example.R"), "# BEGIN", "# END")로 지정합니다.
파일을 읽어 표시할 뿐 R/Python을 실행하지 않습니다.

## R 코드 표시

```typst
#Skylighting(number: true, (
  [#NormalTok("x ")#OperatorTok("<-")#DecValTok(" 1")],
  [#FunctionTok("sqrt")#NormalTok("(2)")],
))
```

이 함수들도 같은 패키지의 : *로 불러옵니다. rcode.Skylighting(...) 문법도 지원합니다.

## PC에서 설치

압축을 푼 패키지/저장소를 다음 경로에 둔다고 가정합니다.
~/Library/CloudStorage/Dropbox/Github/park-typst

```bash
mkdir -p "$HOME/Library/Application Support/typst/packages/local/park-typst"
ln -s "$HOME/Library/CloudStorage/Dropbox/Github/park-typst" \
"$HOME/Library/Application Support/typst/packages/local/park-typst/0.1.0"
```

File exists라면 기존 경로를 확인하고, 덮어쓰거나 삭제하지 마세요.
Calepin 전환 설치 프로그램을 쓸 경우 이 연결도 자동으로 만듭니다.
PC/앱 모두 #import "@local/park-typst:0.1.0": *를 사용합니다.
Typst 0.15.0 이상이 필요합니다.

## 기존 Calepin 책 전환

함께 제공한 park-typst-calepin-bridge.zip을 사용합니다.
이것은 별도 디자인 패키지가 아니라, 교재의 설정/참조 데이터를 park-typst에
전달하는 연결 파일과 백업 설치 프로그램입니다.
01-newton.typ 같은 챕터의 import나 본문은 그대로 사용할 수 있습니다.

## 업데이트

PC에서 공통 패키지 수정 → GitHub push → 앱의 패키지 프로젝트 Pull →
새 버전으로 Publish → 해당 버전을 사용할 문서의 import 변경 순서입니다.
기존 버전으로 만든 원고는 계속 사용할 수 있습니다.
로컬 심볼릭 링크는 현재 작업 파일을 바로 읽으므로 과거 버전 보관은 버전별 복사가 필요합니다.

## 검증 범위

Typst 0.15.1 CLI / Calepin 0.0.61에서 테스트했습니다.
독립 note·slide·exam·코드 읽기·합본 book, 절별 번호 리셋을 컴파일했고,
Calepin 책 프로젝트는 전환 전후 PDF 7개의 렌더링 픽셀과 교차참조 13개가 동일했습니다.
공통 박스 선폭을 한 번 변경해 독립 note와 book에 함께 반영되는 것도 확인했습니다.
웹 앱 계정에 실제 등록하거나 GitHub에 push한 상태는 아닙니다.

학교 로고, 원고별 .bib, 교재별 참조 목록은 패키지에 들어 있지 않습니다.
Calepin의 코드 실행/사이트 생성은 PC에서 수행합니다.
Calepin 원고의 /.calepin import가 웹 앱에서 자동 작동하는 것은 아닙니다.
웹 앱에서는 examples의 독립 문서 구조를 사용합니다.

원본 scienceicons 0.1.0의 raw 문법 경고는 남아 있으나 현재 컴파일은 통과합니다.
기존 책 프로젝트에 있던 LICENSE 파일을 포함했습니다.
