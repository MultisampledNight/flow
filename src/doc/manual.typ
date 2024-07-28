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
#let fill-trigger = regex(
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
)
#let zwsp-hack(body) = body.text.at(0) + "\u{FEFF}" + body.text.slice(1)
#show raw: it => {
  show fill-trigger: zwsp-hack
  it
}
#show fill-trigger: it => {
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
    ("?", [$[ 0, 1 ]$], [Maybe you],    [Maybe]),
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
  - And you might miss things that were your job

=== More examples of tasks

```example
-   [ ] you    _can_ be   extra spacious
- [?] this is long: #lorem(20)

+ [ ] Task lists can also be ordered!
+ [x] And advance as normal!

- [>] This is a large parent task!
  + [x] Which can have subtasks!
  + [>] With even more nesting!
    + [ ] Like here!
    + [ ] And here!

- [ ]No space between checkbox and description needed!
```


=== Examples of non-tasks

They are still completely fine text!
Their checkboxes are just not rendered.

```example
- Still just a normal list entry
- [Bracketized, but fill must be 1 char]
  - [[Well, 1 grapheme cluster :3]]
- [] Fill must not be empty
- [ [ The brackets must be opposite
-[ ] Space must be before checkbox qwq
```


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
