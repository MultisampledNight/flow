// Feel free to import this file's contents via a glob!

#import "callout.typ"
#import "checkbox.typ"
#import "gfx.typ"
#import "metainfo.typ"
#import "palette.typ": *

// global re-exports
#let (question, note, hint, caution) = dictionary(callout)
#let invert = gfx.invert

// global definitions
#let separator = line(length: 100%, stroke: gamut.sample(25%)) + v(-0.5em)

// The args sink is used as metadata.
// It'll exposed both in a table in the document and via `typst query`.
#let template(
  body,
  title: [Untitled],
  ..args,
) = {
  set page(fill: bg, numbering: "1 / 1")
  set text(fill: fg, font: "IBM Plex Sans", size: 14pt)

  set rect(stroke: fg)
  set line(stroke: fg)

  set heading(numbering: "1.1")

  set outline(
    indent: auto,
    fill: move(
      dy: -0.25em,
      line(length: 100%, stroke: gamut.sample(15%)),
    ),
  )

  show link: if dev {
    text.with(duality.blue)
  } else {
    underline
  }
  show raw.where(block: false): it => highlight(
    top-edge: 0.9em,
    bottom-edge: -0.25em,
    fill: luma(0%),
    radius: 0.25em,
    stroke: 4pt + luma(0%),
    text(if dev { fg } else { luma(100%) }, it),
  )
  show raw.where(block: true): it => block(
    fill: luma(0%),
    radius: 0.5em,
    inset: 0.5em,
    text(if dev { fg } else { luma(100%) }, it),
  )

  show outline: it => it + separator

  show: checkbox.process


  text(2.5em, strong(title))

  let info = args.named()
  if info.len() > 0 {
    v(-1.75em)
    metainfo.process(info)
    separator
  }

  body
}


// the actual user code
#show: template.with(
  title: [flow manual],
  aliases: ([flow], [how to procastinate]),
)

#outline()

= how do i use this

+ clone this repository into `{data-dir}/typst/packages/local/flow/0.1.0`

  - where `{data-dir}` is

    - on Linux: `$XDG_DATA_HOME` if set, otherwise `$HOME/.local/share`
    - on macOS: `sh $HOME/Library/Application Support`
    - on Windows: `%APPDATA%`

    (taken from https://github.com/typst/packages?tab=readme-ov-file#local-packages)

+ use the the following boilerplate in your note:

  ```typ
  #import "@local/flow:0.1.0": *
  #show: template
  ```

+ start typing the actual note like any other typst document! uwu

= Checkboxes

== normal and innocent

- [ ] Not started
- [!] Urgent
- [>] In progress
- [:] Paused
- [x] Completed
- [/] Cancelled
- [-] Blocked
- [?] Unknown

== more funny cases which are checkboxes, too

-     [    ]       extra space
- [?] this is really long #lorem(20)

+ [ ] i'm an enum uwu
+ [x] expand me

- [>] parent task
  + [x] nested
  + [>] sub
  + [ ] tasks
    - [ ] extra
    - [ ] nested

  - [ ] ducks

== not checkboxes

- single
- [lmao
- [] collapsed
- [][ who knows
-[ ] oops i missed the space before the checkbox


= Callouts

#question[
  Something that is still to be examined.
]

#note[
  Key takeaways from a section. \
  Should be easy to remember.
]

#hint[
  How to do something more easily. \
  Or something that can be used to remember this better.
]

#caution[
  Tries to warn the reader of something important or dangerous.
]

= Effects

== Invert

For when you need to add #invert[extra importance] to some text.

Note that #invert[it should always fit on one line though,
otherwise it'll go out of page like this one.]

#invert[
  (Or if you really want to use a manual line break, \
  well, the one parallelopiped goes over the whole body. \
  Is that what you wanted?)
]

#v(1.5em)

Hence it is best fit for #invert[a few words.]

= Wishlist

- [ ] Split this file into library and document
- [ ] Custom outline with
  + right-aligned title
  + page number
  + section number
- [ ] Conversion helper from Obsidian's markdown dialect
  - The math part will be the most interesting
- [ ] Doclinks (even clickable?)
