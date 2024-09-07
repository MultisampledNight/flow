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

#let _process(body) = {
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

  slides.map(slide).join()
} 
