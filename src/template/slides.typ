#import "@preview/touying:0.6.1": *

#import "common.typ": *
#import "modern.typ": modern

// avoid recursion
#let typst = (outline: outline)

#let next = pagebreak()

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

#let flow-theme(
  body,
  aspect-ratio: "16-9",
  prefix-title-slide: true,
  banner: none,
  ..args,
) = {
  show: modern.with(..args)
  let (data, title) = _shared(args)

  // https://touying-typ.github.io/docs/build-your-own-theme
  set text(26pt)
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-colors(..slides-scheme),
    config-common(
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

// https://touying-typ.github.io/docs/sections
#let outline = components.adaptive-columns(typst.outline)
