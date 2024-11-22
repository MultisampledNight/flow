#import "cfg.typ"
#import "palette.typ": *

#let separator = line(
  length: 100%,
  stroke: gamut.sample(25%),
) + v(-0.5em)

#let todo(it) = if cfg.dev {
  text(duality.green, emph(it))
}
