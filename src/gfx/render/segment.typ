// Render segment displays.

#import "../util.typ": *
#import "../draw.typ": *

/// Maps from character to which bits are activated for it.
/// in a segment display.
///
/// This is a bijection:
/// Ambiguous characters are assigned exactly one
/// representant.
#let lookup = (
  // t  --------+
  // m  -------+|
  // b  ------+||
  // tl -----+|||
  // tr ----+||||
  // bl ---+|||||
  // br --+||||||
  // dot-+|||||||
  //     vvvvvvvv
  "0": 0b01111101,
  "1": 0b01010000,
  "2": 0b00110111,
  "3": 0b01010111,
  "4": 0b01011010,
  "5": 0b01001111,
  "6": 0b01101111,
  "7": 0b01011001,
  "8": 0b01111111,
  "9": 0b01011111,

  // characters
  "A": 0b01111011,
  "C": 0b00101101,
  "E": 0b00101111,
  "F": 0b00101011,
  "H": 0b01111010,
  "J": 0b01110101,
  "L": 0b00101100,
  "P": 0b00111011,
  "U": 0b01111100,
  "Y": 0b00111010,

  " ": 0b00000000,
)

/// Takes the `n`th bit out of `bits`,
/// returning a boolean.
/// `n` starts from 0:
/// The first bit is `n = 0`,
/// the second one is `n = 1` and so on.
#let _bit(bits, n) = {
  bits.bit-rshift(n).bit-and(1) == 1
}

/// Display one particular bit combination.
/// Use `lookup` to, well, look up which character
/// belongs to which bit combination this function expects.
#let direct(
  bits,
  bottom-left: (0, 0),
  top-right: (1, 2),
  // How much space there is to the next character.

  off: round-stroke() + (paint: gamut.sample(30%)),
  on: round-stroke() + (paint: fg, thickness: 0.15em),
) = group({
  let (bl, tr) = (bottom-left, top-right)

  // Derive the rest of the positions
  let br = (bl, "-|", tr) // Bottom right
  let tl = (bl, "|-", tr) // Top left

  let c = (bl, 50%, tr) // Center
  let cl = (bl, "|-", c) // Center left
  let cr = (c, "-|", tr) // Center right

  let l(start, end, cut: 15%) = line(
    (start, cut, end),
    (start, 100% - cut, end),
  )

  let leds = (
    () => l(tl, tr),
    () => l(cl, cr),
    () => l(bl, br),
    () => l(tl, cl),
    () => l(tr, cr),
    () => l(cl, bl),
    () => l(cr, br),
    () => circle(br, radius: 0.025),
  )
  leds
    .enumerate()
    .map(((n, led)) => {
      let accent = if _bit(bits, n) {
        on
      } else {
        off
      }

      set-style(
        fill: accent.paint,
        stroke: accent,
      )
      led()
    })
    .join()
})

/// Uses several segment displays to show the given text.
#let run(
  /// Text to render.
  /// Must be a string.
  /// Will panic if the chosen segment display
  /// cannot display a character in the text.
  body,
  /// Size of one character.
  size: (1, 2),
  /// Horizontal and vertical space between characters.
  space: (0.5, 0.75),

  ..args,
) = canvas({
  let (width, height) = size
  let (space-h, space-v) = space
  // Logical position in the text at the moment.
  let (x, y) = (0, 0)

  for ch in body.clusters() {
    if ch == "\n" {
      x = 0
      y -= 1
      continue
    }

    let bottom-left = (
      (width + space-h) * x,
      (height + space-v) * y,
    )
    direct(
      lookup.at(ch),
      bottom-left: bottom-left,
      top-right: (rel: size, to: bottom-left),
      ..args,
    )

    x += 1
  }
})
