#import "info.typ"
#import "palette.typ": *
#import "@preview/polylux:0.3.1": *

#let slide(body) = {
  // don't register headings that don't have any content
  // this way one can use a bare `=` for an empty slide
  // and a bare `==` for a new slide without heading
  show heading.where(body: []): set heading(
    numbering: none,
    outlined: false,
  )
  show outline: block.with(width: 60%)
  set outline(depth: 1)
  set line(stroke: (thickness: 0.15em))

  polylux-slide(body)
}

#let prominent(body) = align(center + horizon, {
  set heading(numbering: none, outlined: false)
  show heading: set text(1.5em)

  body
})

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

#let _progress-bar(now, total) = {
  let ratio = (now - 1) / (total - 1)
  move(
    dy: 0.35em,
    line(
      length: ratio * 100%,
      stroke: gamut.sample(35%),
    ),
  )
}

#let _prelude(body) = {
  set page(
    paper: "presentation-16-9",
    footer: context {
      let now = logic.logical-slide.get().first()
      let total = logic.logical-slide.final().first()

      grid(
        columns: (1fr, auto),
        align: (left, right),
        gutter: 0.5em,
        _progress-bar(now, total),
        dim[#now / #total],
      )
    },
  )
  body
}

#let _also-check-children(it, check) = {
  it.fields().at("children", default: (it,)).any(check)
}

#let _is-heading-with(it, check) = _also-check-children(
  it,
  it => (it.func() == heading and check(it.depth))
    or (it.func() == outline and check(1)),
)
#let _is-heading(it) = _is-heading-with(it, _ => true)
#let _is-toplevel-heading(it) = _is-heading-with(it, d => d == 1)
#let _is-subheading(it) = _is-heading-with(it, d => d > 1)

#let _used-slide-delimiter-shorthand(slide) = _also-check-children(
  slide,
  it => "body" in it.fields() and it.body == []
)

// Traverses the body and splits into slides by headings.
// *The body needs to be un-styled for this,
// i.e. call this after before you've applied anything to the content.
// This can be accomplished by putting it as the last show rule
// after all set rules.*
#let _split-onto-slides(body) = {
  _split-by(
    body.children,
    _is-heading,
    edge-action: "right"
  )
  .map(array.join)
}

#let _process-title(slides, args) = {
  // title slide is from first toplevel heading to then-next heading (of any kind)
  let title-start = slides.position(_is-toplevel-heading)
  let title-end = slides.slice(title-start + 1).position(slide =>
    _is-toplevel-heading(slide) or (
      "children" in slide.fields() and
      slide.children.at(0).func() == heading
    )
  ) + title-start + 1

  let title = slides.slice(title-start, title-end).join()
  title = prominent({
    title
    info.render(info.preprocess(args))
  })

  slides.slice(0, title-start).map(slide => {
    set heading(numbering: none)
    align(center + horizon, slide)
  })
  (title,)
  slides.slice(title-end)
}

#let _process-final(slides) = {
  // final slide is everything after last toplevel heading
  let final-start = (
    slides.len() -
    slides.rev().position(_is-toplevel-heading) -
    1
  )

  let final = slides.slice(final-start).join()
  final = prominent(final)

  slides.slice(0, final-start)
  (final,)
}

#let _center-section-headings(slides) = slides.map(slide => {
  // don't want to render something centered just because a slide delimiter was used
  if (
    _used-slide-delimiter-shorthand(slide)
    or not _is-toplevel-heading(slide)
  ) {
    return slide
  }

  align(center + horizon, slide)
})

#let _process(body, handout: false, args) = {
  let slides = _split-onto-slides(body)

  slides = _process-title(slides, args)
  slides = _process-final(slides)

  slides = _center-section-headings(slides)

  enable-handout-mode(handout or not cfg.render)

  slides.map(slide).join()
}