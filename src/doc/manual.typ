#import "../lib.typ": *
#show: template.with(
  title: [flow manual],
  aliases: [how to procastinate],
  author: [MultisampledNight],
  cw: ["you"],
)

#let normal = text.with(font: "IBM Plex Sans")

#show raw.where(lang: "example"): it => {
  let code = it.text
  let label(body) = emph(dim(normal(body + v(-0.5em))))
  grid(
    columns: (1fr, 1fr),
    align: (top + left, left),
    gutter: 1em,
    label[Typst code:]
      + raw(lang: "typ", block: true, code),
    label[Rendered result:]
      + block(
        stroke: fg,
        radius: 0.5em,
        inset: 0.5em,
        width: 100%,
        normal(eval(mode: "markup", code))
      ),
  )
}

// TODO: throw this into gfx?
#let name-to-info = (
  "not started": (gfx.empty, <not-started>),
  "urgent": (gfx.urgent, <urgent>),
  "in progress": (gfx.progress, <in-progress>),
  "paused": (gfx.pause, <paused>),
  "completed": (gfx.complete, <completed>),
  "cancelled": (gfx.cancel, <cancelled>),
  "blocked": (gfx.block, <blocked>),
  "unknown": (gfx.unknown, <unknown>),
)
// i am not sure if i like this or not
#show regex(
  "\b(" +
  name-to-info
    .keys()
    .map(name =>
      "(" + name.at(0) +
      "|" + upper(name.at(0)) +
      ")" +
      name.slice(1)
    )
    .intersperse("|")
    .join() +
  ")\b"
): it => {
  let (icon, to-desc) = name-to-info.at(lower(it.text))
  link(to-desc)[#icon() #it]
}


#outline()

= How do I get started?

+ Clone this repository into `{data-dir}/typst/packages/local/flow/0.1.0`

  - where `{data-dir}` is

    - on Linux: `$XDG_DATA_HOME` if set, otherwise `$HOME/.local/share`
    - on macOS: `sh $HOME/Library/Application Support`
    - on Windows: `%APPDATA%`

    (taken from https://github.com/typst/packages?tab=readme-ov-file#local-packages)

+ Use the the following boilerplate in your note:

  ```typ
  #import "@local/flow:0.1.0": *
  #show: template
  ```

+ Start typing the actual note like any other typst document! uwu

= Reference

== Task

/ Task: Checkbox at the very beginning of a list item or enumeration item.
/ Checkbox: Opening bracket, one fill character or space, closing bracket.

Task lists allow you to gain a quick overview
regarding where you are right now,
what is actionable,
what to next and
what you can't do right now.

They are useful as an *anchor point*,
a single source of truth for yourself to check what you are doing right now.
For longer-form tasks and projects,
you might want to consider using more specialized software
like the ones emulating e.g. Kanban boards.

=== Using them

Just type a list or enum like you're used to (using e.g. `-` or `+`),
then put the desired checkbox right afterwards and pad it with spaces.
That's it!

```example
- [ ] Not started
- [!] Urgent
- [>] In progress
- [:] Paused
- [x] Completed
- [/] Cancelled
- [-] Blocked
- [?] Unknown
```

=== Fill semantics

The variable $p in [0, 1] union RR$ represents the hypothetical current progress
of that task, where $0$ is no progress done yet and $1$ is fully finished.
This is a model: In reality, progress is rarely well quantifiable.
Hence, see these semantics merely as a suggestion.

#table(
  columns: 4,
  align: (center,) + (left,) * 3,
  inset: 0.5em,
  [Fill], [$p in ...$], [Assigned to?], [Actionable by you?],
  ..(
    (" ", [${ 0 }$],    [Nobody yet],   [Yes]),
    ("!", [$[ 0, 1 )$], [You],          [Yes]),
    (">", [$[ 0, 1 )$], [You],          [Yes]),
    (":", [$( 0, 1 )$], [You],          [Yes]),
    ("x", [${ 1 }$],    [Nobody],       [No]),
    ("/", [$[ 0, 1 )$], [Nobody],       [No]),
    ("-", [$[ 0, 1 )$], [Not you],      [No]),
    ("?", [$[ 0, 1 ]$], [Unknown],      [Unknown]),
  )
  .map(((fill, ..args)) => (
    [
      #raw("[" + fill + "]")
      #sym.arrow
      #gfx.icons.at(fill)()
    ],
    ..args,
  )).join()
)

==== Not started <not-started>

- No progress done yet
- May be started by anyone, possibly you

==== Urgent <urgent>

- Should be prioritized when selecting next tasks to put in progress
- Consider putting tasks currently in progress on pause for this instead
- Requires time-sensitive action
- Otherwise like not started

==== In progress <in-progress>

- Not finished yet, but being worked on
- The point you look for when you try to remember what you were doing again
- Ideally keep the count of those as low as possible, if not even just 1

==== Paused <paused>

- Some progress already done
- Can be continued anytime
- Probably some notes flying around already

==== Completed <completed>

- Was fully fulfilled
- Nothing needs to be done anymore

==== Cancelled <cancelled>

- Doesn't need or can't be fulfilled anymore
- Can be just ignored

==== Blocked <blocked>

- Cannot be continued by you for the moment
- Maybe just some time has to pass, maybe somebody else is working on it
- Either way, not your responsibility for the moment

==== Unknown <unknown>

- Maybe some progress is already done, maybe none, maybe it's actually complete
- Maybe it is your responsibility, maybe someone else's
- Need to acquire more information to put it into a "proper" category
- Try to have as few of these as possible as they make planning quite difficult
  - And you may miss things that were your job

=== More examples

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

=== not checkboxes

- single
- [lmao
- [] collapsed
- [][ who knows
-[ ] oops i missed the space before the checkbox


== Callout

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

== Effect

=== Invert

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

- [x] Split into library and manual
- [ ] Custom outline with
  + right-aligned title
  + page number
  + section number
- [ ] Conversion helper from Obsidian's markdown dialect
  - The math part will be the most interesting
- [ ] Doclinks (even clickable?)
- [ ] DAG for possible checkbox transitions
