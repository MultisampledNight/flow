#import "common.typ": *
#import "modern.typ": modern

#let _note-outline = context {
  // When using multiple notes in one document,
  // we want to only show the outline for the headings in the same note
  // notes are delimited by <info> labels (they are before any other content)
  let target = selector(heading.where(outlined: true))
    .after(here())
    .before(selector(<info>).after(here()))

  // Are there any headings? If so, no need to render an outline.
  if query(target).len() == 0 {
    return
  }

  context {
    v(-0.75em)
    outline(target: target)
    separator
  }
}

#let note(body, ..args) = {
  show: modern.with(..args)

  if cfg.render == "all" {
    let (data, title) = _shared(args)

    text(2.5em, strong(title))

    v(-1.75em)
    info.render(forget-keys(data, ("keywords", "title")))
    separator

    _note-outline
  }

  body
}

