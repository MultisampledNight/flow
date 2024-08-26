#import "gfx/util.typ": *
#import "gfx/render.typ" as _render
#import "palette.typ": *

// make the icons easily accessible so that one can just key to 
#let markers = (
  " ": "empty",
  "!": "urgent",
  ">": "progress",
  "x": "complete",
  ":": "pause",
  "-": "block",
  "/": "cancel",
  "?": "unknown",
  "i": "note",
  "o": "hint",
)


// need to convert to a dict so we can access by string key
#let _render = dictionary(_render)
#for (short, long) in markers.pairs() {
  let details = (
    accent: status.at(long),
    icon: _render.at(long),
    long: long,
  )
  markers.insert(short, details)
}

#let parallelopiped(start, end, shift: 0.5, ..args) = {
  import draw: *

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
) = box(context canvas(length: 1em, {
  import draw: *
  let body = pad(right: shift * -1em, pad(..padding, body))

  // idea is to draw 2 parallelopiped
  // then move them slightly above and below
  // so they don't affect layouting
  // but are still displayed out of line
  let size = measure(body)
  let half-backdrop = box(canvas(length: 1em, {
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

// Highlight the first grapheme cluster
// (can approximately think of it as a character)
// of each word
// using the given function.
#let fxfirst(it, fx: strong) = {
  it.split()
    .map(word => {
      let clusters = word.clusters()
      let first = fx(clusters.first())
      let rest = clusters.slice(1).join()
      [#first#rest]
    })
    .intersperse[ ]
    .join()
}
