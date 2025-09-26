#import "/src/lib.typ" as flow: * // this would be your @preview/flow:... import
#import template.slides: *

#show: flow-theme.with(
  title: "Cats are amazing",
  subtitle: [And here's why],
  presenter: [MultisampledNight],
  when: "2025-09-26 03:05:00",
  banner: gfx.canvas(length: 3em, {
    import gfx.draw: *

    let o = (0, 0)
    let mirror(
      it,
      horizontal: true,
      vertical: false,
      pivot: o,
    ) = {
      let dimension(axis, double, body) = group({
        body
        if double {
          set-origin(pivot)
          scale(..((axis, -1),).to-dict())
          body
        }
      })

      let it = dimension("x", horizontal, it)
      let it = dimension("y", vertical, it)

      it
    }

    mirror(line((0, 0.75), (1, 1.5), (1, 0)))
    circle(o, radius: 1, fill: bg)
    mirror(arc(
      (0.25, 0.15),
      start: 180deg,
      stop: 0deg,
      radius: 0.5em,
    ))

    let nose = (0, -0.125)
  }),
)

= Animals

:neocat_floof:

== Cats are very cool

- Sometimes fluffy
- Sometimes playful
- Always interesting

-> Definitely worth considering

== Squirrels

- Unique insight into our mind
- They persevered evolution .•. chaotic != bad!
- I forgot what I wanted to write here
- Oh, a squirrel!

= Cryptography

== Mreow

== Symmetric --- there's just 1 key

== Asymmetric --- 2 of them

#todo[Image of 2 cats]

