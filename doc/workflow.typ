#import "/src/lib.typ" as flow: *
#let accent = ("root", "vertex", "yield", "edge").zip(
  duality.values().slice(2)
)
#let steps = gradient-map(
  ("initialize", "gather", "extract", "condense", "refine"),
  (duality.orange, duality.yellow, duality.green),
)
#let bold = ("source", "target", "incoming", "outgoing").map(name => (name, strong))
#show: note.with(
  title: "Multi's workflow",
  author: "MultisampledNight",
  version: version(0, 1, 0),
  keywords: (accent + bold).to-dict() + steps,
)

This document lays out
my personal knowledge management system.
It is tuned to *my* needs.
Hence, it is unlikely to work exactly this way for you.
Feel free to take what seems useful
and change or leave what you don't find so.

= Structure folders — `~/notes`

All notes live in `~/notes`,
which is also what the environment variable
`$TYPST_ROOT` is set to.
The contents of that folder
are described in the following sections.

== `_do`

Projects,
what I'm currently working on,
when I need to just write down
some creative thoughts:
All of that comes here.

== `_follow`

Usually unstructured information dumps
that stem from
conferences,
lectures,
meetings,
chats and
other kinds of
mostly-uncontrolled interactions.
These dumps are usually great roots.

== `_learn`

Descriptions and observations about the world.
Here, much use of semantic grouping is made
so that notes themselves don't have to specify their context all over again.

For example,
take this real note path:

```
_learn/science/mathematics/analysis/function/property/Kernel.typ
```

There's a few things to find out using that path:

- The note itself has `Kernel.typ` as filename.
- However, looking at the path before,
  it is a *property* of *functions*.
  - There might also be other notes called `Kernel`,
    but this specific one is in the *context* of functions.
- It is generally in the domain of mathematics.

The tree below `_learn` very large,
hence I'll only list the general categories.

=== `art`

Art has lots of possible definitions,
my favorite one is that
it is anything that conveys deep meaning.
Hence, it can be explored and interacted with
by asking good questions.

However, this also covers the topics adjacent to art:
media,
audience,
color,
creation,
gamedev,
architecture,
design,
composition,
communication,
semiotics,
...

=== `language`

Specialization of communication,
language covers a partly-agreed-upon
set of messages to convey meaning more effectively.

This specifically focuses on natural and constructed languages,
but not programming languages.
Those belong to computer science.

=== `project-planning`

How to structure longer projects in a way that they ideally don't fail.

=== `science`

Anything that accepts and utilizes the scientific method
to gain knowledge, usually a combination of
empirical experimentation and
rational reasoning.

Examples include
biology,
chemistry,
computer science,
cryptography,
cybernetics,
engineering,
epistemology,
ethics,
geography,
history,
linguistics,
mathematics,
medicine,
metaphysics,
philosophy,
physics,
psychoolgy,
rhethorics and
sociology.

I hang out a lot here.
I like it.
Antiscience is not science, by the way.

=== `tech`

Real-world practical hardware and software,
products or self-built.

=== `work`

How to apply for jobs,
how to avoid crunch,
how to avoid companies that want crunch,
the works.

=== `world`

Anything that
exists or
used to exist
in the real world#footnote[
Whatever that is.
].

Examples include
buildings,
cities,
clubs,
collectives,
companies,
countries,
dates,
entities,
epochs,
events,
food,
governments,
groups,
institutions,
legalities,
movements,
museums,
organizations,
politics,
procedures,
religion,
sports,
talks,
unions and
universities.

== `_self`

Myself, my thoughts and anything personal.
This is generally highly confidential.
Existential thoughts at 02:00
in the morning go here.

== `attachment`

Images, videos, larger things
that should not pollute the other folders
but still be somewhat near reachable and referrable to.

== `zero`

"System" and general things,
such as taskkeeping and notes
that don't really belong anywhere else semantically.

=== `daily-note`

Contains one note for each day
in RFC 3339 format#footnote[
`YYYY-MM-DD`
].
Usually instantiated from a dedicated template.

=== `tasks`

`short-term`, `long-term` and `life` task lists.
See @tasks.

=== `template`

== `ref.yml`

This is actually a file
using Hayagriva @hayagriva!
It contains _everything_
I cite in my notes.
This makes it very easy to include it in a note,
all one needs to write is
`#bibliography("/ref.yml")` anywhere and
`@name` to cite `name`.

= Acquire knowledge

== Idea

The flow of information in my knowledge
can be represented as
#fxfirst("Directed Graph").
Its components have the following meanings:

/ Vertex:
  A codification of information.
  - Examples: Note, reference, manual, webpage, video, verbal communication

  / Root:
    A vertex without incoming edges.
    Where information originally stems from.

  / Yield:
    A vertex without outgoing edges.
    Final product that can be given to others and
    presented to a wider audience without worries.

  / Source:
    A vertex $a$ which has an outgoing edge
    which is also an incoming edge of a given vertex $b$.

  / Target:
    The given vertex $b$ in the definition of source.

/ Edge:
  A vertex influencing another vertex directly and significantly.
  - Generally the vertices which one is viewing while modifying a vertex.
  - There's a lot of subjective leeway here on what is "influence".

This allows gamification:
Given a set of roots,
find the smallest and easiest comprehensible yield
without sacrificing too much on accuracy.

As a side effect, if one isn't happy with the current yield,
one is never bound to it.
Either the yield itself can be modified,
or a new yield can be created with the current yield as basis.

== Application

The general high-level algorithm I use this with is the following:

+ *Initialize* via a spark that piques interest in a topic.
  - Sometimes it's a cool talk on https://media.ccc.de.
  - Sometimes it's a friend telling a story.
  - Sometimes it's having to look into a complicated problem.
+ *Gather* external resources to use as roots.
+ *Extract* relevant information out of the roots into new vertices.
+ *Condense* existing vertices into new vertices.
  - Note that _all_ vertices can be used as sources.
+ *Refine* until a satisfying yield is reached.
  - By condensing ever further.
  - Possibly also gathering and extracting new roots if needed.

In an ideal world,
one would would have infinitely much time for every step.
Realistically though,
one will need to weigh off time investments.

For example,
if it's known one has a presentation of a paper at some point,
then the presentation and paper should both be yields, ideally.
Things never go clean though
— so it's okay if it doesn't work out.

The theoretical model is nice and all,
but most of the time I actually don't have it in my mind.
Instead, at the bottom of a note
is usually a section `References` or `Resources`
where I put all links, talks and notes this is an effect of into
without thinking too much of them as roots.

== Evaluation

=== Advantages

- High learning throughput via high abstraction.
  - When in a hurry,
    I only need to remember how yields interact,
    not their entire content.

=== Downsides

- High repetition.
  - Sometimes, the same things are typed several times
    and "carried" across vertices without much thought.
  - This requires individual discipline to counteract.

= Accomplish tasks <tasks>

== Definitions

Each task is in exactly one *phase* $P$:

/ Today's daily note: $P_d$
/ Short-term tasks: $P_S$
/ Long-term tasks: $P_L$

Additionally, each task is in exactly one *state* $S$.
The possible states are,
with each checkbox it corresponds to in flow:

/ Not started: $S_N$, `[ ]`
  - Still open and to do.
/ In progress: $S_P$, `[>]`
  - What I'm working on right now.
/ On hold: $S_H$, `[:]`
  - Already somewhat progressed but not worked on right now.
/ Blocked: $S_T$, `[-]`
  - Cannot do this myself at the moment,
    somebody else may be doing it or
    one needs to wait for it.
/ Unknown: $S_Q$, `[?]`
  - Need to investigate to find the actual current state.
/ Finished: $S_F$, `[x]`
  - Completed and fulfilled.
/ Cancelled: $S_L$, `[/]`
  - Not possible or not planned
    to do this anymore.

On top of _that_, a task can be *urgent* or not,
which corresponds to it being in $U$ or not.

There are certain *descriptions*
that can apply to tasks:

/ Active: $D_A = S_N union S_P union S_H union S_Q$
  - I could start advancing this right now.
/ Passive: $D_P = D_A union S_T$
  - I should keep an eye on this,
    even if I can't do anything right now.

Mathematically speaking, $P_*, S_*, D_*, U$ are sets.

=== Notation reference

- $t in M$ means the task $t$ is in a set $M$.
  - The opposite is $t in.not M$.

- $t -> M$ means to move the task $t$ into the set $M$,
  removing it from another set if that'd violate any rule stated above.
  - For example,
    if $t in P_d$,
    $t -> P_S$ would cause
    $t in.not P_d$ afterwards.

- $forall A : B$ means
  "For all $A$,
  make sure $B$ is upheld"#footnote[
    Simplified, like most other mathematic explanations here.
  ]

- $A and B$ means that both $A$ and $B$ have to be true
  in order for the whole expression to be true.

- $A or B$ means that any of $A$, $B$ or both must be true
  in order for the whole expression to be true.

- $A inter B$ contains all tasks that are in *both* sets $A$ and $B$.

- $A union B$ contanis all tasks that are in *any* of the sets $A$ or $B$.


== Events and actions

An *event*
is a certain circumstance
that can be observed.
An *action*
is something that is done.

Each section here describes an event in its heading and
the accompanying conditional actions in its body.

#let c = table.cell
#set table(align: center + horizon, inset: 0.5em)

=== Day starts

+ Go through the entirety of the current $P_d$ and $P_S$.
+ Think which ones can be reasonably done today.
+ Transfer those $t -> P_d$.

=== Day ends

$ forall t in P_d inter D_P : t -> P_S $

=== $P_S$ becomes too short, long or boring

Add a new task maintenance to $P_S$,
see @maintenance.

=== A new task $n$ arises

#table(
  columns: 3,
  table.header[Urgency][Necessary today?][Assigned phase],
  c(rowspan: 2, $n in U$),
    [Yes], $n in P_t$,
    [No], $n in P_S$,
  $n in.not U$,
    [No], $n in P_L$,
)

== Maintenance <maintenance>

+ Clean:
  Transfer all _stale_ tasks from $P_S$ to $P_L$.
  - A stale task is unlikely to see progress in the next few weeks and
    does not require consideration in the short run.

+ Deconstruct:
  $forall t in P_L$,
  think if $t$ would benefit
  from splitting it up into smaller bite-sized pieces.
  Do so if so.

+ Reach:
  Transfer tasks that one
    wants to do and
    likely can do
  the next few weeks
  from $P_L$ to $P_S$

== Motivation

In today's complex world,
it can feel quite meaningless to do anything
due to there always being more and more.
It's easy to get lost in an ocean of responsibilities,
metaphorically speaking.
The other extreme of planning into the smallest detail
can be equally dreadful though.

This system tries to strike a balance:

- Avoid being overwhelmed by _the world_.
  - Define phases and states concisely.
  - Make it possible to just follow the actions for each event.
  - One can trust the guarantees it provides.

- Avoid being overwhelmed by _this system_.
  - Keep the event and action count low.
  - Leave enough ambiguity for interruptions and experiments.
  - Allow deviations and be transparent.

Personally, I think this tradeoff is desirable.
It often helps to look back at what one has done in the past,
for both
emotional#footnote[
  "Yay, I finished this! Woohoo!"
] and
optimization#footnote[
  "If a similar situation arises,
  I should distribute more over the whole week."
]
reasons.
Still I don't want to spend all my time tracking myself.
I do need to give myself enough space to be creative in.

There might be other tradeoffs or even extreme choices
desirable for other entities.
E.g. somebody who hates writing will probably not like any kind of tracking.
I'd be interested in hearing _your_ system, still.


#bibliography("ref.yml")
