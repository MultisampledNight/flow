#import "@preview/cetz:0.2.2"

#import "palette.typ": *

#let _icon(
  body,
  // if true, render the actual icon itself in bg on a rounded rectangle with the accent.
  // if false, render only the icon itself.
  invert: true,
  // if `invert` is true, the radius of the accent rect
  radius: 0.25,
  // the key under which to look information like accent up.
  // if neither this nor `accent` is set, default to the fg color.
  key: none,
  // overrides `key` if set. the color to tint the icon in.
  accent: none,
  ..args,
) = box(
  inset: (y: -0.25em),
  cetz.canvas(..args, length: 1em, {
    import cetz.draw: *

    let accent = if accent != none {
      accent
    } else {
      status.at(key, default: fg)
    }

    let icon-accent = accent
    if invert {
      rect(
        (0, 0), (1, 1),
        stroke: none,
        fill: accent,
        radius: radius,
      )
      icon-accent = bg
    } else {
      // hacking the boundary box in so the spacing is right
      line((0, 0), (1, 1), stroke: none)
    }

    // intended to be selectively disabled via passing `none` explicitly
    set-style(
      stroke: (
        cap: "round",
        join: "round",
        paint: icon-accent,
      ),
      fill: icon-accent,
    )

    // so the user can just draw from 0 to 1 while the padding is outside
    set-origin((0.2, 0.2))
    scale(0.6)
    body
  })
)

#let progress = _icon.with(key: "progress", {
  import cetz.draw: *
  let bendness = (x: 0.25, y: 0.5)
  let offset = 0.25

  for shift in (-offset, offset) {
    line(
      (0.5 - bendness.x + shift, 0.5 + bendness.y),
      (0.5 + bendness.x + shift, 0.5),
      (0.5 - bendness.x + shift, 0.5 - bendness.y),
      fill: none,
    )
  }
})

#let complete = _icon.with(key: "complete", {
  import cetz.draw: *

  line((0, 0), (1, 1))
  line((0, 1), (1, 0))
})

#let unknown = _icon.with(key: "unknown", {
  import cetz.draw: *

  arc(
    (0.5, 0.5),
    start: 165deg,
    stop: -90deg,
    fill: none,
    radius: 0.25,
    anchor: "arc-end",
  )
  line(
    (0.5, 0.5),
    (0.5, 0.3),
  )
  circle(
    (0.5, 0.05),
    radius: 0.5pt,
  )
})

#let icons = (
  progress: progress,
  complete: complete,
  unknown: unknown,
)


// just showcasing them
#set page(width: auto, height: auto)

#grid(
  columns: 2,
  align: (right, left),
  gutter: 0.75em,
  [*Name*], [*Icon*],
  ..icons.pairs().map(
    ((name, icon)) => (
      [#name],
      move(dy: 0.175em, icon()),
    )
  ).join(),
)

