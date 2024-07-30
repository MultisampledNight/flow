#import "gfx.typ"
#import "palette.typ": *

#let _callout(body, accent: fg, marker: none) = {
  let body = if marker == none {
    body
  } else {
    let icon = gfx.markers.at(marker).icon
    grid(
      columns: (1.5em, auto),
      gutter: 0.5em,
      align: (right + horizon, left),
      icon(invert: false),
      body,
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

#let question = _callout.with(
  accent: status.unknown,
  marker: "?",
)
#let note = _callout.with(
  accent: status.note,
  marker: "i",
)
#let hint = _callout.with(
  accent: status.hint,
  marker: "o",
)
#let caution = _callout.with(
  accent: status.urgent,
  marker: "!",
)
