#import "../lib.typ" as flow: *
#show: template

#gfx.diagram(length: 5em, {
  import gfx.draw: *
  trans(
    (0, 0),
    (1, 0),
    styled(
      stroke: (paint: blue),
      (2, 0),
      styled(
        stroke: (thickness: 0.5em),
        (3, 0),
        styled(
          stroke: (dash: "dashed"),
          (4, 0),
        ),
      ),
    ),
  )
})
