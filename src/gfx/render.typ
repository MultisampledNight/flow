// Actual implementations of individual rendered icons.

#import "util.typ": *
#import "draw.typ": *

#let empty(
  // argument is simply ignored
  // since it is always just a shallow outline
  invert: true,
  ..args,
) = icon(
  invert: true,
  key: "empty",
  ..args,
() => {
  rect((-0.125, -0.125), (1.125, 1.125), radius: 0.25)
})

#let urgent = icon.with(key: "urgent", () => {
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

#let progress = icon.with(key: "progress", () => {
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

#let pause = icon.with(key: "pause", () => {
  circle((0.5, 0.8), radius: 0.1)
  circle((0.5, 0.2), radius: 0.1)
})

#let block = icon.with(key: "block", () => {
  line((0, 0.5), (1, 0.5))
})

#let complete = icon.with(key: "complete", () => {
  line((0, 0), (1, 1))
  line((0, 1), (1, 0))
})

#let cancel = icon.with(key: "cancel", () => {
  let slantedness = 0.25

  line(
    (0.5 - slantedness, 0),
    (0.5 + slantedness, 1),
  )
})

#let unknown = icon.with(key: "unknown", () => {
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
    radius: 0.05em,
  )
})

#let remark = icon.with(key: "remark", () => {
  circle((0.5, 0.95), radius: 0.5pt)
  line((0.5, 0.65), (0.5, 0))
})

#let hint = icon.with(key: "hint", () => {
  circle((0.5, 0.5), radius: 0.5, fill: none)
})
