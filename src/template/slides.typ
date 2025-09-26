// mostly based on:
// https://touying-typ.github.io/docs/build-your-own-theme
// https://touying-typ.github.io/docs/sections

#import "@preview/touying:0.6.1": *

#import "common.typ": *
#import "modern.typ": modern

// avoid recursion
#let typst = (outline: outline)

#let next = pagebreak()
#let pseudo-heading(it, scale: 1) = text(
  1.25em * scale,
  strong(it),
)

#let slide(
  header: self => pseudo-heading(
    utils.display-current-short-heading(),
  ),
  footer: self => context fade({
    h(1fr)
    utils.slide-counter.display()
    [ #sym.slash ]
    utils.last-slide-number
  }),
  ..args,
) = touying-slide-wrapper(self => {
  // yes, this is intentional. even the example does this,
  // so i assume this is an example of "exposed" internals? /j
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (rest: 0.5em, top: 3.5em),
      header: header,
      footer: footer,
    ),
  )

  touying-slide(self: self, ..args)
})

#let split-slide(
  west,
  east,
  main: right,
  ..args,
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

  set align(horizon)

  slide(
    composer: sizes,
    align(mid, west),
    align(left + horizon, east),
    ..args,
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
  footer: none,
)

#let outline = {
  show: slide.with(header: none, footer: none)
  set align(mid)
  set outline(depth: 1)

  show: box.with(width: 60%)

  (typst.outline)()
}

#let new-section-slide(section) = touying-slide-wrapper(
  self => {
    touying-slide(self: self, {
      set align(mid)
      show: pseudo-heading.with(scale: 2)
      utils.display-current-short-heading()
    })
  },
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

  set text(24pt)
  show: touying-slides.with(
    config-page(paper: "presentation-" + aspect-ratio),
    config-colors(..slides-scheme),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
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
