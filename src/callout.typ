#import "gfx/mod.typ" as gfx
#import "palette.typ": *

#let callout(body, accent: none, marker: none) = {
  let accent = if accent != none {
    accent
  } else if marker != none {
    gfx.markers.at(marker).accent
  } else {
    fg
  }
  let body = if marker == none {
    body
  } else {
    let icon = gfx.markers.at(marker).icon
    grid(
      columns: (1.5em, 1fr),
      gutter: 0.5em,
      align: (right + horizon, left),
      icon(invert: false), body,
    )
  }

  block(
    stroke: (left: accent),
    inset: (
      left: if marker == none { 0.5em } else { 0em },
      y: 0.5em,
    ),
    body,
  )
}

#let (
  (question, remark, hint, caution),
  (define, axiom, theorem, lemma, propose, corollary),
) = ("?io!", "datlpc").map(chs => chs
  .clusters()
  .map(marker => callout.with(marker: marker)))

