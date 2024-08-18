// Utilities for defining icons and other graphics.

#import "@preview/cetz:0.2.2"
#import "../palette.typ": *
#import "draw.typ"

#let round-stroke(paint: fg) = (
  cap: "round",
  join: "round",
  paint: paint,
)

#let canvas(body, length: 1em, ..args) = cetz.canvas(
  ..args,
  length: length,
{
  import draw: *

  set-style(
    stroke: round-stroke(),
  )

  body
})

#let icon(
  body,
  // if true, render the actual icon itself in bg on a rounded rectangle with the accent.
  // if false, render only the icon itself.
  invert: true,
  // if `invert` is true, the radius of the accent rect
  radius: 0.25,
  // the key under which to look information like accent up from `palette.status`.
  // if neither this nor `accent` is set, default to the fg color.
  key: none,
  // overrides `key` if set. the color to tint the icon in.
  accent: none,
  // If true, returns a `content` that can be directly put into text.
  // If false, returns an array of draw commands that can be used in a cetz canvas.
  contentize: true,
  // If `contentize` is false, put the lower left corner of this icon at this position.
  at: (0, 0),
  name: none,
  // Arguments to forward to `canvas` if `contentize` is true.
  ..args,
) = {
  import draw: *

  let cmds = group(
    ..if name != none {
      (name: name)
    } else {
      (:)
    },
    {
      set-origin(at)

      let accent = if accent != none {
        accent
      } else {
        status.at(key, default: fg)
      }

      let icon-accent = accent
      if invert {
        rect(
          (0, 0),
          (1, 1),
          stroke: none,
          fill: accent,
          radius: radius,
          ..if name != none {
            (name: name)
          } else {
            (:)
          }
        )
        icon-accent = bg
      } else {
        // hacking the boundary box in so the spacing is right
        line((0, 0), (1, 1), stroke: none)
      }

      // intended to be selectively disabled via passing `none` explicitly
      set-style(
        stroke: (paint: icon-accent),
        fill: icon-accent,
      )

      // so the user can just draw from 0 to 1 while the padding is outside
      set-origin((0.2, 0.2))
      scale(0.6)
      body
    },
  )

  if contentize {
    box(
      inset: (y: -0.175em),
      canvas(..args, cmds)
    )
  } else {
    cmds
  }
}

#let diagram(nodes: (:), edges: (:), body: none, ..args) = {
  let cmds = {
    import draw: *
    for (name, pos) in nodes {
      content(pos, name, name: name)
    }

    for (from, to) in edges {
      trans(from, to)
    }

    body
  }

  align(center, canvas(cmds, ..args))
}
