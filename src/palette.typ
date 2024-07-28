#let duality = (
  fg: rgb("#B6B3B4"),
  bg: rgb("#212224"),

  pink: rgb("#FA86CE"),
  violet: rgb("#AAA9FF"),
  blue: rgb("#00C7F7"),

  orange: rgb("#FF9365"),
  yellow: rgb("#C7B700"),
  green: rgb("#11D396"),
)

#let print = (
  fg: luma(0%),
  bg: luma(100%),
)

#let dev = json.decode(sys.inputs.at("dev", default: "false"))

#let fg = if dev { duality.fg } else { print.fg }
#let bg = if dev { duality.bg } else { print.bg }
#let gamut = gradient.linear(bg, fg, space: oklch)
#let dim(body) = text(fill: gamut.sample(60%), body)

#let status = (
  empty: gamut.sample(75%),
  urgent: if dev { duality.orange },
  progress: if dev { duality.violet },
  pause: if dev { duality.green },
  block: if dev { duality.blue },
  complete: fg,
  cancel: gamut.sample(40%),
  unknown: if dev { duality.yellow },

  note: if dev { duality.green } else { green },
  hint: if dev { duality.violet } else { purple },
)
#for (name, value) in status {
  if value == none {
    // so we don't have to type out the non-dev case all the time
    value = fg
  }
  status.at(name) = value
}

#let reference = (
  external: if dev { duality.blue } else { blue },
  other-file: if dev { duality.violet } else { purple },
  same-file: if dev { duality.green } else { green },
)
