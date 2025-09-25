#import "common.typ": *
#import "generic.typ": generic

/// Compromise between generic and note.
/// Does not display any content but uses nice, legible fonts.
#let modern(body, ..args) = {
  set text(font: "IBM Plex Sans", size: 14pt)
  show raw: set text(
    font: "JetBrainsMonoNL NF",
    weight: "light",
  )

  set par(linebreaks: "optimized")
  show: generic.with(..args)

  body
}
