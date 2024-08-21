#import "../lib.typ" as flow: *
#show: template.with(
  title: [flow manual],
  aliases: [how to procastinate],
  author: [MultisampledNight],
  cw: "\"you\"",
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
        normal(eval(
          mode: "markup",
          scope: dictionary(flow),
          code,
        ))
      ),
  )
}

#let name-to-info = (
  "not started": (" ", <not-started>),
  "urgent": ("!", <urgent>),
  "in progress": (">", <in-progress>),
  "paused": (":", <paused>),
  "completed": ("x", <completed>),
  "cancelled": ("/", <cancelled>),
  "blocked": ("-", <blocked>),
  "unknown": ("?", <unknown>),
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
  let (marker, to-desc) = name-to-info.at(lower(it.text))
  let icon = gfx.markers.at(marker).icon
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
  columns: 5,
  align: left,
  inset: 0.5em,
  [_Name_],         [_Fill_], [$p in ...$], [_Assigned to?_], [_Actionable by you?_],
  ..(
    ([Not started], " ",      [${ 0 }$],    [Nobody yet],   [Yes]),
    ([Urgent],      "!",      [$[ 0, 1 )$], [You],          [Yes]),
    ([In progress], ">",      [$[ 0, 1 )$], [You],          [Yes]),
    ([Paused],      ":",      [$( 0, 1 )$], [You],          [Yes]),
    ([Completed],   "x",      [${ 1 }$],    [Nobody],       [No]),
    ([Cancelled],   "/",      [$[ 0, 1 )$], [Nobody],       [No]),
    ([Blocked],     "-",      [$[ 0, 1 )$], [Not you],      [No]),
    ([Unknown],     "?",      [$[ 0, 1 ]$], [Maybe you],    [Maybe]),
  )
  .map(((name, fill, ..args)) => (
    name,
    raw("[" + fill + "]"),
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

== Diagram

/ Diagram: Visually explains a certain concept in a canvas,
  usually in the context of accompanying text.
/ State: Frozen state of certain properties.
  Usually represented by a node.
/ Transition: Properties changing from one state to another.
  Usually represented by an edge.U
/ Canvas: Set of elements drawn into a confined `content`.

Some minds like to build graphical representations
of thought models in addition to having them just described in text.
Diagrams fill this role.

They are useful as a second line for conveying concepts.
They do not replace a text description though:
Since Typst doesn't support PDF accessibility yet,
it is highly recommended that they don't add any new information
that isn't in the text already

Ultimately though your documents are your documents,
so use them as you see fit.

== Using them

For drawing, manipulating and connecting shapes,
the `gfx` module is your friend,
which re-exports
#link("https://typst.app/universe/package/cetz")[cetz]
and adds neat helpers.
Assumed you've glob-imported all out of `flow`,
the usual boilerplate for a diagram looks like this:

```example
A typical rock-paper-scissors game
consists of all players deciding for one of
*rock*, *paper* or *scissors*,
where:

#let rock = oklch(60%, 0.2, 60deg)
#let paper = rock.rotate(120deg)
#let scissors = paper.rotate(120deg)

+ #text(rock)[*Rock*]
  loses to #text(paper)[*paper*]
+ #text(paper)[*Paper*]
  loses to #text(scissors)[*scissors*]
+ #text(scissors)[*Scissors*]
  loses to #text(rock)[*rock*]

#import gfx.draw: *
#let beats(it) = tag(
  it,
  tag: emph(text(0.8em)[beats]),
  anchor: "south",
  angle: it,
  padding: 0.1,
)
#gfx.diagram(
  nodes: (
    rock: (
      pos: (angle: -150deg, radius: 1),
      accent: rock,
    ),
    paper: (
      pos: (angle: -30deg, radius: 1),
      accent: paper,
    ),
    scissors: (
      pos: (angle: 90deg, radius: 1),
      accent: scissors,
    ),
  ),
  edges: (
    paper: beats("rock"),
    scissors: beats("paper"),
    rock: beats("scissors"),
  ),
  length: 4em,
)
```

= Wishlist

- [x] Split into library and manual
- [x] Transition graph for possible checkbox transitions
  - [x] Initial version
  - [x] Color edges
  - [x] Try alternative layouts
- [x] `diagram` helpers that facilitate and index diagrams (like the one with the checkbox transitions)
  - Probably just need to add a bit of sugar to what's already in this document
  - Actually lol for the tags and the works I can just re-use the stack mechanism
  - Modifiers like `styled` and `tag` can just open a new depth
  - If there's no `reset-to`, it's not... reset to, lol
- [ ] Custom outline with
  + right-aligned title
  + page number
  + section number
- [ ] Conversion helper from Obsidian's markdown dialect
  - The math part will be the most interesting
- [ ] Doclinks (even clickable?)
- [ ] Checkbox continuation and quick checking from `EmulateObsidian` function into typst
