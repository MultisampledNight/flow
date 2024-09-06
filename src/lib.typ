// Feel free to import this file's contents via a glob!
// See `doc/manual.typ` for an example of how usage in practise looks like!

#import "callout.typ": question, note, hint, caution
#import "cfg.typ"
#import "checkbox.typ"
#import "gfx.typ" as gfx: invert, fxfirst
#import "info.typ"
#import "palette.typ": *
#import "terms.typ"

// global definitions
#let separator = line(length: 100%, stroke: gamut.sample(25%)) + v(-0.5em)

// The args sink is used as metadata.
// It'll exposed both in a table in the document and via `typst query`.
#let template(
  body,
  title: none,
  outlined: true,
  ..args,
) = {
  let title = if title != none {
    title
  } else if cfg.filename != none {
    cfg.filename.trim(
      ".typ",
      at: end,
      repeat: false,
    )
  } else {
    [Untitled]
  }

  set document(
    title: title,
    author: args.named().at("author", default: ()),
  )
  set page(
    fill: bg,
    numbering: "1 / 1",
    header: if not cfg.render {
      align(center, strong(emph[
        No-render mode — intended for `typst query`, not viewing
      ]))
    },
    // PERF: consistently shaves off 0.02 seconds of query time
    // tested on i7 10th gen
    ..if not cfg.render {
      (width: auto, height: auto)
    }
  )
  set text(
    fill: fg,
    font: cfg.font.body,
    size: if cfg.render { 14pt } else { 0pt },
    lang: args.named().at("lang", default: "en"),
  )
  show raw: set text(font: cfg.font.code)
  show math.equation: set text(font: cfg.font.math)

  set rect(stroke: fg)
  set line(stroke: fg)
  set table(stroke: fg)

  set heading(numbering: "1.1")

  set outline(
    indent: auto,
    fill: move(
      dy: -0.25em,
      line(length: 100%, stroke: gamut.sample(15%)),
    ),
  )

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
  show raw.where(block: false): it => highlight(
    top-edge: 0.9em,
    bottom-edge: -0.25em,
    fill: luma(0%),
    radius: 0.25em,
    stroke: 4pt + luma(0%),
    extent: 0em,
    text(if cfg.dev { fg } else { luma(100%) }, it),
  )
  show raw.where(block: true): it => block(
    fill: luma(0%),
    radius: 0.5em,
    inset: 0.5em,
    width: 100%,
    text(if cfg.dev { fg } else { luma(100%) }, it),
  )


  text(2.5em, strong(title))

  if args.named().len() > 0 {
    v(-1.75em)
    info.process(args.named())
    separator
  }

  if outlined and cfg.render {
    outline()
    separator
  }

  show: checkbox.process
  show: terms.process.with(cfg: args.named().at("terms", default: none))

  body
}
