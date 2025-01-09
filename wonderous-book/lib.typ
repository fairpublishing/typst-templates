#let book(
  // The book's title
  title: [Book title],

  // The book's author
  author: "Author",

  // The book's translator (new parameter)
  translator: none,

  // The book's cover image (new parameter)
  cover-image: none,

  // Copyright information (new parameter)
  copyright-info: none,

  // ISBN number (new parameter)
  isbn: none,

  // Publishing info
  publishing-info: none,

  // A dedication to display
  dedication: none,

  // The book's content
  body,
) = {
  // Keep the existing pagebreak detection function
  let detectable-pagebreak(to: "odd") = {
    [#metadata(none) <empty-page-start>]
    pagebreak(to: to)
    [#metadata(none) <empty-page-end>]
  }

  // Keep the existing is-page-empty function
  let is-page-empty() = {
    let page-num = here().page()
    query(<empty-page-start>)
      .zip(query(<empty-page-end>))
      .any(((start, end)) => {
        (start.location().page() < page-num
          and page-num < end.location().page())
      })
  }

  // Set the document's metadata
  set document(title: title, author: author)
  set text(font: "EB Garamond 08")
  set page(width: 5.2in, height: 8in)

  // Cover image page
  if cover-image != none {
    page(margin: 0pt,
      align(center + horizon)[
        #image(cover-image, width: 100%)
      ]
    )
    pagebreak(to: "odd")
  }

  // Title-only page
  page(align(center + horizon)[
    #text(2.5em)[*#title*]
  ])
  pagebreak(to: "odd")

  // Full title page with author and translator
  page(align(center + horizon)[
    #text(2em)[*#title*]
    #v(2em, weak: true)
    #text(1.6em, author)
    #if translator != none {
      v(1em, weak: true)
      text(1.2em)[#translator]
    }
  ])
  pagebreak(to: "even")

  // Copyright and publishing information page
  {
    set text(size: 0.8em)
    grid(
      columns: (1fr),
      gutter: 1em,
      if copyright-info != none [ #copyright-info ],
      if publishing-info != none [ #publishing-info ],
      if isbn != none [ ISBN: #isbn ],
    )
  }
  pagebreak(to: "odd")

  // Dedication page (if provided)
  if dedication != none {
    v(15%)
    align(center, strong(dedication))
    pagebreak(to: "odd")
  }

  // Configure paragraph properties
  set par(spacing: 0.78em, leading: 0.78em, first-line-indent: 12pt, justify: true)

  // Configure page properties (keep existing header configuration)
  set page(
    header: context {
      if is-page-empty() {
        return
      }

      let i = here().page()
      if query(heading).any(it => it.location().page() == i) {
        return
      }

      let before = query(selector(heading).before(here()))
      if before != () {
        set text(0.95em)
        let header = smallcaps(before.last().body)
        let title = smallcaps(title)
        let author = text(style: "italic", author)
        grid(
          columns: (1fr, 10fr, 1fr),
          align: (left, center, right),
          if calc.even(i) [#i],
          if calc.even(i) { author } else { title },
          if calc.odd(i) [#i],
        )
      }
    },
  )

  // Keep existing heading configuration
  show heading.where(level: 1): it => {
    detectable-pagebreak(to: "odd")
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }
    v(5%)
    text(2em, weight: 700, block([#number #it.body]))
    v(1.25em)
  }
  show heading: set text(11pt, weight: 400)

  body
}
