#import "@preview/cetz:0.2.2"

#import "palette.typ": *

#let _icon(
  body,
  // if true, render the actual icon itself in bg on a rounded rectangle with the accent.
  // if false, render only the icon itself.
  invert: true,
  // if `invert` is true, the radius of the accent rect
  radius: 0.25,
  // the key under which to look information like accent up from `palette`'s `status`.
  // if neither this nor `accent` is set, default to the fg color.
  key: none,
  // overrides `key` if set. the color to tint the icon in.
  accent: none,
  ..args,
) = box(
  inset: (y: -0.175em),
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


#let empty(
  // argument is simply ignored
  // since it is always just a shallow outline
  invert: true,
  ..args,
) = _icon(
  invert: true,
  key: "empty",
  ..args,
{
  import cetz.draw: *

  rect((-0.125, -0.125), (1.125, 1.125), radius: 0.25)
})

#let urgent = _icon.with(key: "urgent", {
  import cetz.draw: *
  let offset = 0.2

  for (offset, y-scale) in (
    ((x: -offset, y: 0), 1),
    ((x: offset, y: 1), -1),
  ) {
    line(
      (0.5 + offset.x, 1 * y-scale + offset.y),
      (0.5 + offset.x, 0.35 * y-scale + offset.y),
    )
    circle(
      (0.5 + offset.x, 0.05 * y-scale + offset.y),
      radius: 0.5pt,
    )
  }
})

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

#let pause = _icon.with(key: "pause", {
  import cetz.draw: *

  circle((0.5, 0.8), radius: 0.1)
  circle((0.5, 0.2), radius: 0.1)
})

#let block = _icon.with(key: "block", {
  import cetz.draw: *

  line((0, 0.5), (1, 0.5))
})

#let complete = _icon.with(key: "complete", {
  import cetz.draw: *

  line((0, 0), (1, 1))
  line((0, 1), (1, 0))
})

#let cancel = _icon.with(key: "cancel", {
  import cetz.draw: *
  let slantedness = 0.25

  line(
    (0.5 - slantedness, 0),
    (0.5 + slantedness, 1),
  )
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
    (0.5, 0.35),
  )
  circle(
    (0.5, 0.05),
    radius: 0.5pt,
  )
})

#let note = _icon.with(key: "note", {
  import cetz.draw: *

  circle((0.5, 0.95), radius: 0.5pt)
  line((0.5, 0.65), (0.5, 0))
})

#let hint = _icon.with(key: "hint", {
  import cetz.draw: *

  circle((0.5, 0.5), radius: 0.5, fill: none)
})

#let icons = (
  " ": empty,
  "!": urgent,
  ">": progress,
  "x": complete,
  ":": pause,
  "-": block,
  "/": cancel,
  "?": unknown,
  "i": note,
  "o": hint,
)


#let parallelopiped(start, end, shift: 0.5, ..args) = {
  import cetz.draw: *

  line(
    start,
    (start, "-|", end),
    (to: end, rel: (shift, 0)),
    (to: (start, "|-", end), rel: (shift, 0)),
    close: true,
    ..args,
  )
}

// Draws any content over a parallelopiped.
// Very useful for making a few words extra clear.
#let invert(
  accent: fg,
  shift: 0.5,
  padding: (x: 1em),
  body
) = box(context cetz.canvas(length: 1em, {
  import cetz.draw: *
  let body = pad(right: shift * -1em, pad(..padding, body))

  // idea is to draw 2 parallelopiped
  // then move them slightly above and below
  // so they don't affect layouting
  // but are still displayed out of line
  let size = measure(body)
  let half-backdrop = box(cetz.canvas(length: 1em, {
    parallelopiped(
      (0, 0),
      (size.width, size.height),
      shift: shift,
      fill: accent,
      stroke: accent,
    )
  }))
  content((0, 0), move(dx: shift * 1em, dy: -size.height / 2, half-backdrop))
  content((), move(dy: size.height / 2, half-backdrop))
  content((), text(fill: bg, body))
})) + h(0.75em, weak: true)


// just showcasing them
#set page(width: auto, height: auto)

#grid(
  columns: 2,
  align: (right, left),
  gutter: 0.75em,
  [*Name*], [*Icon*],
  ..icons.pairs().map(
    ((name, icon)) => (
      raw("\"" + name + "\""),
      move(dy: 0.175em, icon()),
    )
  ).join(),
)

