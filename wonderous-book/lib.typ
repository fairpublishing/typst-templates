// This function gets your whole document as its `body` and formats
// it as a simple fiction book.
#let book(
  // The book's title.
  title: [Book title],

  // The book's author.
  author: "Author",

  // A dedication to display on the third page.
  dedication: none,

  // Details about the book's publisher that are
  // display on the second page.
  publishing-info: none,

  // The book's content.
  body,
) = {
  // Creates a pagebreak to the given parity where empty pages
  // can be detected via `is-page-empty`.
  let detectable-pagebreak(to: "odd") = {
    [#metadata(none) <empty-page-start>]
    pagebreak(to: to)
    [#metadata(none) <empty-page-end>]
  }

  // Workaround for https://github.com/typst/typst/issues/2722
  let is-page-empty() = {
    let page-num = here().page()
    query(<empty-page-start>)
      .zip(query(<empty-page-end>))
      .any(((start, end)) => {
        (start.location().page() < page-num
          and page-num < end.location().page())
      })
  }

  // Set the document's metadata.
  set document(title: title, author: author)


  // Alternatives are:
  // - "Georgia"
  // - "Crimson Text", download the .ttf files from Adobe
  // - "EB Garamond 08" ou "EB Garamond 12", install with apt install fonts-ebgaramond
  // - "TeX Gyre Pagella", used by wonderous-book by default, install with apt install tex-gyre
  //
  // https://www.reddit.com/r/selfpublish/comments/1d3nr1g/what_fonts_do_you_use_in_your_printed_books/?rdt=36609
  // https://images.squarespace-cdn.com/content/v1/626468793ed4b669a65c7631/3f326379-d750-45f4-bf3d-afb90fef24d0/Font+chart.jpg
  //
  // Other: Adobe Caslon, Minion Pro, Adobe Garamond, Sabon
  // Original comment: Set the body font. TeX Gyre Pagella is a free alternative
  // to Palatino.
  set text(font: "EB Garamond 08")

  set page(width: 5.2in, height: 8in)

  // The first page.
  page(align(center + horizon)[
    #text(2em)[*#title*]
    #v(2em, weak: true)
    #text(1.6em, author)
  ])

  // Display publisher info at the bottom of the second page.
  if publishing-info != none {
    align(center + bottom, text(0.8em, publishing-info))
  }

  pagebreak()

  // Display the dedication at the top of the third page.
  if dedication != none {
    v(15%)
    align(center, strong(dedication))
  }

  // Books like their empty pages.
  pagebreak(to: "odd")

  // Configure paragraph properties.
  set par(spacing: 0.78em, leading: 0.78em, first-line-indent: 12pt, justify: true)

  // Start with a chapter outline.
  // outline(title: [Chapters])
  // pagebreak(to: "odd", weak: true)

  // Configure page properties.
  set page(
    // The header always contains the book title on odd pages and
    // the author on even pages, unless
    // - we are on an empty page
    // - we are on a page that starts a chapter
    header: context {
      // Is this an empty page inserted to keep page parity?
      if is-page-empty() {
        return
      }

      // Are we on a page that starts a chapter?
      let i = here().page()
      if query(heading).any(it => it.location().page() == i) {
        return
      }

      // Find the heading of the section we are currently in.
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
          // Swap `author` and `title` around, or possibly with `heading`
          // to change what is displayed on each side.
          if calc.even(i) { author } else { title },
          if calc.odd(i) [#i],
        )
      }
    },
  )

  // Configure chapter headings.
  show heading.where(level: 1): it => {
    // Always start on odd pages.
    detectable-pagebreak(to: "odd")

    // Create the heading numbering.
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
