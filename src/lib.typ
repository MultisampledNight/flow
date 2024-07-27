#import "gfx.typ"

#let _graceful-slice(it, start, end, default: []) = {
  if end == -1 {
    end = it.len()
  }

  let missing = calc.max(start, end - it.len(), 0)
  it += (default,) * missing
  it.slice(start, end)
}

#let _fill_to_icon = (
  ">": "progress",
  "x": "complete",
)

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
  let icon-name = _fill_to_icon.at(fill, default: "unknown")
  let checkbox = gfx.icons.at(icon-name, default: "unknown")
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
  show list.item: _checkboxize.with(kind: "list")
  show enum.item: _checkboxize.with(kind: "enum")

  body
}

#show: template

= Checkboxes

== normal and innocent

- [ ] Not started
- [>] In progress
- [:] Paused
- [x] Completed
- [/] Cancelled
- [-] Blocked

== more funny cases which are checkboxes, too

-     [    ]       extra space

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


