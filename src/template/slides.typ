// mostly based on https://touying-typ.github.io/docs/build-your-own-theme

#import "@preview/touying:0.6.1": *

#import "common.typ": *
#import "modern.typ": modern

// avoid recursion
#let typst = (outline: outline)

#let next = pagebreak()

#let sidebar(actual) = self => h(2em) + fade(actual(self))

/// Ordinary, not anything special. Use `touying-slide` for full control.
#let slide(..args) = touying-slide-wrapper(self => {
  // yes, this is intentional. even the example does this,
  // so i assume this is an example of "exposed" internals? /j
  self = utils.merge-dicts(
    self,
    config-page(
      header: sidebar(self => {
        utils.display-current-short-heading()
      }),
    ),
  )

  touying-slide(self: self, ..args)
})

#let split-slide(
  west,
  east,
  main: right,
) = {
  assert(
    main in (left, right),
    message: "say which side should be larger",
  )

  let sizes = (golden-ratio * 1fr, 1fr)
  let sizes = if main == right {
    sizes.rev()
  } else {
    sizes
  }

  show: slide
  set align(horizon)
  set page(margin: 0pt)

  grid(
    columns: sizes,
    align: (center, left),
    west,
    east,
  )
}

#let title-slide(
  body,
  title: "Untitled",
  subtitle: none,
  ..data,
) = split-slide(
  body,
  (
    text(2em, strong(title)),
    subtitle,
    info.render(data.named()),
  )
    .filter(part => part != none)
    .join[\ ],
)

// https://touying-typ.github.io/docs/sections
#let outline = slide(context {
  set align(mid)
  set outline(depth: 1, title: none)
  show: box.with(width: 60%)

  (typst.outline)()
})

#let flow-theme(
  body,
  aspect-ratio: "16-9",
  prefix-title-slide: true,
  banner: none,
  ..args,
) = {
  show: modern.with(..args)
  let (data, title) = _shared(args)

  set text(28pt)
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-colors(..slides-scheme),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: section => touying-slide-wrapper(
        self => {
          touying-slide(self: self, {
            set align(mid)
            utils.display-current-short-heading()
          })
        },
      ),
    ),
  )

  if prefix-title-slide {
    title-slide(
      banner,
      title: title,
      ..data,
    )
  }

  body
}
