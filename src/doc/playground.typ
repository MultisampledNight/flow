#import "../lib.typ" as flow: *
#show: template
#gfx.diagram(length: 5em, {
  import gfx.draw: *
  trans(
    (0, 0),
    (1, 0),
    br(styled((1, 1), stroke: blue)),
    br(tag((1, -1), tag: [useful edge])),
  )
})
