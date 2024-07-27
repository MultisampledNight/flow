#let fg = luma(0%)
#let bg = luma(100%)
#let gamut = gradient.linear(bg, fg, space: oklch)

#let status = (
  empty: gamut.sample(50%),
  urgent: orange,
  progress: purple,
  pause: red,
  block: teal,
  complete: fg,
  cancel: blue,
  unknown: green,
)
