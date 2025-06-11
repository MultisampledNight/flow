#import "gfx/mod.typ" as gfx
#import "info.typ"
#import "palette.typ": *

#let callout(
  body,
  /// Color that the callout is highlighted with.
  accent: none,
  /// Icon to show at the left. Is just a string containing 1 cluster, stored in `gfx.markers`.
  /// If `accent` is `none` (the default), this is also where the highlight color is taken from instead.
  marker: none,
  /// Who said or wrote down what is in that callout.
  author: none,
  /// How this callout should be titled.
  name: none,
) = {
  let accent = if accent != none {
    accent
  } else if marker != none {
    gfx.markers.at(marker).accent
  } else {
    fg
  }

  let body = [
    *#name*

    #body

    #if author != none [ \~#info.render(author) ]
  ]
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

