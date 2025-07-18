#import "asset.typ"
#import "cfg.typ"
#import "checkbox.typ"
#import "hacks.typ"
#import "info.typ"
#import "keywords.typ"
#import "palette.typ": *
#import "util/mod.typ": *
#import "xlink.typ"

#let _shortcuts(body) = {
  (
    "->": sym.arrow,
    "=>": sym.arrow.double,
    "!=": sym.eq.not,
    "<=>": sym.arrow.l.r.double,
    "<>": sym.harpoons.rtlb,
    // can be just typed with .<shift on>.<shift off>. on Bone (https://neo-layout.org/Layouts/bone/)
    ".•.": $therefore$,
    "•.•": $because$,
  )
    .pairs()
    .fold(body, (body, (source, target)) => {
      show: hacks.only-main(source, target)
      body
    })
}

#let _numbering(body, ..args) = {
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")

  body
}

#let _machinize(body, ..args) = {
  // PERF: consistently shaves off 0.02 seconds of query time
  // tested on i7 10th gen
  set page(width: auto, height: auto)
  set text(size: 0pt)

  show: _numbering

  body
}

#let _styling(body, ..args) = context {
  if cfg.render != "all" {
    return _machinize(body, ..args)
  }

  let args = args.named()
  let faded-line = move(dy: -0.25em, line(length: 100%, stroke: gamut.sample(
    15%,
  )))

  show: _numbering

  set outline.entry(fill: faded-line)
  set outline(indent: auto)

  show: body => if cfg.target == "paged" {
    set page(fill: bg, numbering: "1 / 1")
    body
  } else {
    body
  }
  set text(fill: fg, lang: args.at("lang", default: "en"))

  set rect(stroke: fg)
  set line(stroke: fg)
  set table(inset: 0.75em, stroke: (x, y) => {
    if x > 0 { (left: gamut.sample(30%)) }
    if y > 0 { (top: gamut.sample(30%)) }
  })

  set math.mat(delim: "[")
  set math.vec(delim: "[")

  show: _shortcuts

  show ref: text.with(fill: reference.same-file)
  show link: it => {
    let accent = if type(it.dest) == str {
      reference.external
    } else {
      reference.same-file
    }
    let ret = text(fill: accent, it)
    if not cfg.dev { ret = underline(ret) }
    ret
  }

  let cb = (
    fill: halcyon.bg,
    radius: 0.25em,
  )

  set raw(theme: asset.halcyon)
  show raw: text.with(fill: halcyon.fg)
  show raw.where(block: false): it => box(
    outset: (y: 0.3em),
    inset: (x: 0.25em),
    it,
    ..cb,
  )
  show raw.where(block: true): it => block(
    inset: 0.75em,
    width: 100%,
    stroke: 0.025em + gradient.linear(halcyon.bg, halcyon.fg).sample(40%),
    it,
    ..cb,
  )

  show table: align.with(center)

  body
}

#let _shared(args) = {
  let data = info.preprocess(args.named())
  let title = args.at("title", default: {
    if cfg.filename != none {
      cfg.filename.trim(".typ", repeat: false)
    } else {
      "Untitled"
    }
  })

  (data: data, title: title)
}

/// The args sink is used as metadata.
/// It'll exposed both in a table in the document and via `typst query`.
/// See the manual for details.
#let generic(body, ..args) = {
  let (data, title) = _shared(args)

  show: _styling.with(..data)
  show: keywords.process.with(cfg: data.at("keywords", default: none))
  show: maybe-do(data.at("xlink", default: true), xlink.process)
  show: maybe-do(data.at("checkbox", default: true), checkbox.process)

  set document(title: title, author: data.at("author", default: ()))

  info.queryize(data)
  body
}

/// Compromise between generic and note.
/// Does not display any content but uses nice, legible fonts.
#let modern(body, ..args) = {
  set text(font: "IBM Plex Sans", size: 14pt)
  show raw: set text(font: "JetBrainsMonoNL NF", weight: "light")

  set par(linebreaks: "optimized")
  show: generic.with(..args)

  body
}

#let gfx(body, ..args) = {
  show: modern.with(..args)
  set page(width: auto, height: auto)

  body
}

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

#let latex-esque(body, ..args) = {
  set text(font: "New Computer Modern", size: 12pt)
  show raw: set text(font: "FiraCode Nerd Font Mono")

  show: generic.with(..args)

  set par(justify: true)
  set outline(title: [Table of contents], fill: repeat[.])

  if cfg.render == "all" {
    let (data, title) = _shared(args)

    let title = text(2em, strong(title))

    let extra = data
      .pairs()
      .filter(((key, value)) => key != "title")
      .map(((key, value)) => (
        (upper(key.at(0)) + key.slice(1)).replace("Cw", "Content warning"),
        if type(value) in (str, int, float, content) {
          value
        } else if type(value) == array {
          value.join([, ], last: [ and ])
        } else if type(value) == dictionary {
          value.keys().join[, ]
        } else {
          repr(value)
        },
      ).join[: ])
      .join[\ ]

    align(center, {
      title
      [\ ]
      v(0.25em)
      extra
    })

    outline()
  }

  body
}
