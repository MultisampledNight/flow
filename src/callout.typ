#import "gfx.typ"
#import "palette.typ": *

#let _callout(body, accent: fg, icon: none) = {
  let body = if icon == none {
    body
  } else {
    grid(
      columns: (1.5em, auto),
      gutter: 0.5em,
      align: (right + horizon, left),
      gfx.icons.at(icon)(invert: false),
      body,
    )
  }

  block(
    stroke: (left: accent),
    inset: (
      left: if icon == none { 0.5em } else { 0em },
      y: 0.5em,
    ),
    body,
  )
}

#let question = _callout.with(
  accent: status.unknown,
  icon: "?",
)
#let note = _callout.with(
  accent: status.note,
  icon: "i",
)
#let hint = _callout.with(
  accent: status.hint,
  icon: "o",
)
#let caution = _callout.with(
  accent: status.urgent,
  icon: "!",
)
