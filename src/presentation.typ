#import "info.typ"
#import "@preview/polylux:0.3.1": *

#let slide(body) = polylux-slide(body)

// Splits the array `seq` based on the function `check`.
// `check` is called with each element in `seq` and
// needs to return a boolean.
// Elements that `check` returns true for are called *edges*.
// Each edge marks a split.
// What the edge is done with is determined by `edge-action`:
//
// - "discard" causes the edge to be forgotten.
//   It is neither in the ended nor started array.
// - "isolate" puts the edge into its own array
//    between the just ended and started ones.
// - "right" puts the edge as the *first* item
//    in the *just started* array.
#let _split-by(seq, check, edge-action: "discard") = {
  if edge-action not in ("discard", "isolate", "right") {
    panic()
  }

  let out = ()

  for ele in seq {
    let is-edge = check(ele)
    if is-edge {
      out.push(())
      
      if edge-action == "discard" {
        continue
      }
    }

    if out.len() == 0 {
      out.push(())
    }
    // indirectly also handles "right" == edge-action
    out.last().push(ele)

    if is-edge and edge-action == "isolate" {
      out.push(())
    }
  }

  out
}

#let _prelude(body) = {
  set page(
    paper: "presentation-16-9",
    footer: [
      #logic.logical-slide.display()
      of
      #utils.last-slide-number
    ],
  )
  body
}

// Traverses the body and splits into slides by headings.
// *The body needs to be un-styled for this,
// i.e. call this after before you've applied anything to the content.
// This can be accomplished by putting it as the last show rule
// after all set rules.*
#let _split-onto-slides(body) = {
  // the toplevel headings get their own slides each
  let sections = _split-by(
    body.children,
    it => it.func() == heading and it.fields().depth == 1,
    edge-action: "isolate"
  )
  // while every other heading is atop of its corresponding content
  let slides = sections
    .map(section => _split-by(
      section,
      it => it.func() == heading and it.fields().depth != 1,
      edge-action: "right",
    ))
    .join()
    .map(slide => slide.join())

  slides
}

#let _is-heading-with(it, check) = {
  it.func() == heading and check(it.depth)
}
#let _is-toplevel-heading(it) = _is-heading-with(it, d => d == 1)
#let _is-subheading(it) = _is-heading-with(it, d => d > 1)

#let _center-section-headings(slides) = slides.map(
  slide => if _is-toplevel-heading(slide) {
    align(center + horizon, slide)
  } else {
    slide
  }
)

#let _process-title(slides, args) = {
  // title slide is from first toplevel heading to then-first subheading
  let title-start = slides.position(_is-toplevel-heading)
  let title-end = slides.slice(title-start).position(slide =>
    "children" in slide.fields() and
    _is-subheading(slide.children.at(0))
  ) - 1

  let title = slides.slice(title-start, title-end).join()
  title = align(center + horizon, {
    set heading(numbering: none)
    show heading: set text(1.5em)

    title

    info.render(info.preprocess(args))
  })

  slides.slice(0, title-start)
  (title,)
  slides.slice(title-end)
}

#let _process-finish(slides) = {
  // finish slide is everything after last toplevel heading
  slides
}

#let _process(body, args) = {
  let slides = _split-onto-slides(body)
  slides = _process-title(slides, args)
  slides = _process-finish(slides)
  slides = _center-section-headings(slides)

  slides.map(slide).join()
} 
