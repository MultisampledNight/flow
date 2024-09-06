#import "@preview/polylux:0.3.1": *

#let _prelude(body) = {
  set page(
    paper: "presentation-16-9",
    footer: [
      #logic.logical-slide.display()
      of
      #utils.last-slide-number
    ],
  )
  body
}

#let _process(body) = {
  set text(size: 26pt)

  body
} 
