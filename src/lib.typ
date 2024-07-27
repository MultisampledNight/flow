#import "gfx.typ"
#import "palette.typ" as palette: bg, fg, gamut, dev

#let _graceful-slice(it, start, end, default: []) = {
  if end == -1 {
    end = it.len()
  }

  let missing = calc.max(start, end - it.len(), 0)
  it += (default,) * missing
  it.slice(start, end)
}

#let _checkboxize(it, kind: "list") = {
  let body = it.body.fields().at(
    "children",
    default: (it.body,),
  )
  let checkbox = _graceful-slice(body, 0, 3)

  let is-checkbox = checkbox.at(0) == [\[] and checkbox.at(-1) == [\]]
  if not is-checkbox {
    return it
  }

  // convert the fill character to a showable icon
  let fill = checkbox.at(1).fields().at("text", default: " ")
  let checkbox = gfx.icons.at(fill, default: "?")
  // just a few minor tweaks
  let checkbox = box(move(dx: -0.1em, checkbox()))

  // and remove the description from the checkbox itself
  let desc = _graceful-slice(body, 4, -1).join()
  
  // then throw them together
  let full-entry = [#checkbox #desc]

  if kind == "list" {
    [- #full-entry]
  } else if kind == "enum" {
    [+ #full-entry]
  }
}

#let template(body) = {
  set page(fill: bg)
  set text(fill: fg, font: "IBM Plex Sans", size: 14pt)

  show list.item: _checkboxize.with(kind: "list")
  show enum.item: _checkboxize.with(kind: "enum")

  show link: if dev {
    text.with(palette.duality.blue)
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
    inset: 8pt,
    text(if dev { fg } else { luma(100%) }, it),
  )

  body
}


// the actual user code
#show: template

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


