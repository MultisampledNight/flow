// Interlinks between notes.
// Not intended to be used for yields.

#import "palette.typ": *
#import "hacks.typ"

// TODO: actually implement link. probably gotta be some URL scheme handler magic
// don't forget to write docs
/// Link to another note.
#let xlink(target, display: auto) = {
  display = if display == auto {
    target
  }

  show: text.with(fill: reference.other-file)
  show: underline

  display
}

#let apply(it) = {
  let it = it.text.slice(1, -1)
  xlink(it)
}

#let process-one(it) = context {
  let after-bibliography = (
    query(heading.where(body: [Bibliography]).before(here())).len() > 0
  )
  if after-bibliography {
    it
  } else {
    apply(it)
  }
}

#let process(body, ..args) = {
  let nonzws = "[^" + sym.zws + "]"
  show: hacks.only-main(regex("\[" + nonzws + ".+?\]"), process-one)

  body
}

