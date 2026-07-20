#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

#let slides(
  content,
  title: none,
  subtitle: none,
  footer-title: none,
  footer-subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  ratio: 4/3,
  title-color: none,
  first-slide: true,
  bg-color: white,
  count: "dot",
  footer: true,
  toc: true,
  theme: "normal",
) = {
  if layout not in layouts {
    panic("Unknown layout " + layout)
  }
  let (height, space) = layouts.at(layout)
  let width = ratio * height

  if count not in (none, "dot", "number", "dot-section") {
    panic("Unknown Count, valid counts are 'dot' and 'number', or none")
  }
  if theme not in ("normal", "full") {
    panic("Unknown Theme, valid themes are 'full' and 'normal'")
  }

  if title-color == none {
    title-color = blue.darken(50%)
  }
  let block-color = title-color.lighten(90%)
  let body-color  = title-color.lighten(80%)
  let header-color = title-color.lighten(65%)
  let fill-color  = title-color.lighten(50%)

  set document(title: title, author: authors)
  set heading(numbering: "1.a")

  set page(
    fill: bg-color,
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.6 * space),

    header: [
      #context {
        let page = here().page()
        let headings = query(selector(heading.where(level: 2)))
        let heading = headings.rev().find(x => x.location().page() <= page)
        if heading != none {
          set align(top)
          if (theme == "full") {
            block(
              width: 100%, fill: title-color,
              height: space * 0.85, outset: (x: 0.5 * space)
            )[
              #set text(1.4em, weight: "bold", fill: bg-color)
              #v(space / 2)
              #heading.body
              #if not heading.location().page() == page [
                #{numbering("(i)", page - heading.location().page() + 1)}
              ]
            ]
          } else if (theme == "normal") {
            set text(1.4em, weight: "bold", fill: title-color)
            v(space / 2)
            heading.body
            if not heading.location().page() == page [
              #{numbering("(i)", page - heading.location().page() + 1)}
            ]
          }
        }
      }

      #if count == "dot" {
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          let limit = calc.ceil(last/2)
          if last > 20 {
            v(-space / 1.3)
            for i in range(1, limit+1) {
              if i <= current {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt+fill-color))]
              } else {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.06cm, stroke: 1pt+fill-color))]
              }
            }
            v(-space/1.6)
            linebreak()
            for i in range(limit+1, last+1) {
              if i <= current {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt+fill-color))]
              } else {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.06cm, stroke: 1pt+fill-color))]
              }
            }
          } else {
            v(-space / 1.5)
            for i in range(1, last+1) {
              if i <= current {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color))]
              } else {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, stroke: 1pt+fill-color))]
              }
            }
          }
        }
      } else if count == "dot-section" {
        v(-space / 1.5)
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          let sections = query(heading.where(level: 1))
          let current_section_nr = counter(heading).get().at(0)
          let current_section_page = {
            if current_section_nr > 0 {
              sections.at(int(current_section_nr - 1)).location().page()
            } else { 1 }
          }
          let next_section_page = {
            if current_section_nr < int(sections.len()) {
              sections.at(int(current_section_nr)).location().page()
            } else { last }
          }
          if next_section_page - current_section_page < 3 {
          } else if current_section_nr < int(sections.len()) {
            link((page:current_section_page, x:0pt, y:0pt))[
              #box(rotate(-90deg)[#polygon.regular(stroke: 1pt+fill-color, size: 0.2cm, vertices: 3)]) #h(0.1cm)
            ]
            for i in range(current_section_page+1, next_section_page) {
              if i <= current {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color))]
              } else {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, stroke: 1pt+fill-color))]
              }
            }
            link((page:next_section_page, x:0pt, y:0pt))[
              #h(0.1cm) #box(rotate(90deg)[#polygon.regular(stroke: 1pt+fill-color, size: 0.2cm, vertices: 3)])
            ]
          } else {
            link((page:current_section_page, x:0pt, y:0pt))[
              #box(rotate(-90deg)[#polygon.regular(stroke: 1pt+fill-color, size: 0.2cm, vertices: 3)]) #h(0.1cm)
            ]
            for i in range(current_section_page+1, next_section_page+1) {
              if i <= current {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt+fill-color))]
              } else {
                link((page:i, x:0pt, y:0pt))[#box(circle(radius: 0.08cm, stroke: 1pt+fill-color))]
              }
            }
          }
        }
      } else if count == "number" {
        v(-space / 1.5)
        set align(right + top)
        context {
          let last = counter(page).final().first()
          let current = here().page()
          set text(weight: "bold")
          set text(fill: white) if theme == "full"
          set text(fill: title-color) if theme == "normal"
          [#current / #last]
        }
      }
    ],
    header-ascent: 0%,

    footer: [
      #if footer == true {
        set text(0.7em)
        if (theme == "full") {
          columns(2, gutter: 0cm)[
            #align(left)[#block(
              width: 100%, outset: (left: 0.5*space, bottom: 0cm),
              height: 0.3*space, fill: fill-color, inset: (right: 3pt)
            )[
              #v(0.1*space)
              #set align(right)
              #smallcaps()[#if footer-title != none { footer-title } else { title }]
            ]]
            #align(right)[#block(
              width: 100%, outset: (right: 0.5*space, bottom: 0cm),
              height: 0.3*space, fill: body-color, inset: (left: 3pt)
            )[
              #v(0.1*space)
              #set align(left)
              #if footer-subtitle != none {
                footer-subtitle
              } else if subtitle != none {
                subtitle
              } else if authors != none {
                if (type(authors) != array) { authors = (authors,) }
                authors.join(", ", last: " and ")
              } else [#date]
            ]]
          ]
        } else if (theme == "normal") {
          box()[#line(length: 50%, stroke: 2pt+fill-color)]
          box()[#line(length: 50%, stroke: 2pt+body-color)]
          v(-0.33cm)
          grid(
            columns: (1fr, 1fr),
            align: (right, left),
            inset: 4pt,
            [#smallcaps()[#if footer-title != none { footer-title } else { title }]],
            [#if footer-subtitle != none {
              footer-subtitle
            } else if subtitle != none {
              subtitle
            } else if authors != none {
              if (type(authors) != array) { authors = (authors,) }
              authors.join(", ", last: " and ")
            } else [#date]],
          )
        }
      }
    ],
    footer-descent: 0.3*space,
  )

  show heading.where(level: 1): x => {
    set page(header: none, footer: none, margin: 0cm)
    set align(horizon)
    grid(
      columns: (1fr, 3fr), inset: 10pt, align: (right, left),
      fill: (title-color, bg-color),
      [#block(height: 100%)],
      [#text(1.2em, weight: "bold", fill: title-color)[#x]]
    )
  }

  show heading.where(level: 2): pagebreak(weak: true)
  show heading: set text(1.1em, fill: title-color)
  show heading.where(level: 3): set heading(numbering: none)

  show terms.item: it => {
    stack(
      block(width: 100%, inset: 5pt, fill: header-color, radius: (top: 0.2em, bottom: 0cm), strong(it.term)),
      block(width: 100%, inset: 5pt, fill: block-color, radius: (top: 0cm, bottom: 0.2em), it.description),
    )
  }

  show raw.where(block: false): it => {
    box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(it)]
  }
  show raw.where(block: true): it => {
    block(radius: 0.5em, fill: block-color, width: 100%, inset: 1em, it)
  }

  show list: set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[-],
  ))

  let color_number(nrs) = text(fill: title-color)[*#nrs.*]
  set enum(numbering: color_number)

  show table: set table(
    stroke: (x, y) => (
      x: none,
      bottom: 0.8pt+black,
      top: if y == 0 { 0.8pt+black } else if y == 1 { 0.4pt+black } else { 0pt },
    )
  )
  show table.cell.where(y: 0): set text(style: "normal", weight: "bold")
  set table.hline(stroke: 0.4pt+black)
  set table.vline(stroke: 0.4pt)

  set quote(block: true)
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color, inset: 5pt, radius: 1pt,
      stroke: (left: 3pt+fill-color), width: 100%,
      outset: (left: -5pt, right: -5pt, top: 5pt, bottom: 5pt)
    )[#it]
    v(-5pt)
  }

  show link: it => {
    if type(it.dest) != str { it }
    else { underline(stroke: 0.5pt+title-color)[#it] }
  }

  set outline(indent: auto)
  show outline: set heading(level: 2)
  set bibliography(title: none)

  show ref: it => {
    if it.element != none {
      let el = it.element
      set text(size: 0.7em, fill: white)
      box(
        fill: fill-color, outset: (x: 0.0em, y: 0.2em),
        radius: 0.8em, height: 0.8em, inset: (x: 0.5em),
      )[
        #if el.func() == heading and it.supplement == auto {
          link(el.location(), el.body)
        } else if el.func() == heading {
          link(el.location(), it.supplement.text)
        } else { it }
      ]
    } else { return it }
  }

  if (title == none) {
    panic("A title is required")
  } else if (first-slide == false) {
    // skip default title slide
  } else {
    if (type(authors) != array) { authors = (authors,) }
    set page(footer: none, header: none, margin: 0cm)
    block(
      inset: (x: 0.5*space, y: 1em), fill: title-color,
      width: 100%, height: 60%,
      align(bottom)[#text(2.0em, weight: "bold", fill: bg-color, title)]
    )
    block(
      height: 30%, width: 100%,
      inset: (x: 0.5*space, top: 0cm, bottom: 1em),
      if subtitle != none { [#text(1.4em, fill: title-color, weight: "bold", subtitle)] } +
      if subtitle != none and date != none { text(1.4em)[ \ ] } +
      if date != none { text(1.1em, date) } +
      align(left+bottom, authors.join(", ", last: " & "))
    )
  }

  if (toc == true) { outline() }

  content
}
