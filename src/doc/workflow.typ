#import "../lib.typ" as flow: *
#show: note.with(
  title: "Multi's workflow",
  author: "MultisampledNight",
  keywords: ("root", "vertex", "yield", "edge")
    .zip(duality.values().slice(2)).to-dict(),
)

This is tuned to my needs.
Chances are you want something else.
Feel free to take what seems useful
and change or leave what you don't find so.

= Idea

The flow of information in my knowledge
can be represented as
#fxfirst("Directed Graph").
Its components have the following meanings:

/ Vertex:
  A codification of information.
  - Examples: Note, reference, manual, webpage, video, verbal communication

/ Edge:
  A vertex influencing another vertex directly and significantly.
  - Generally the vertices that one is viewing while modifying a vertex.
  - There's a lot of subjective leeway here on what is "influence".

/ Root:
  A vertex without incoming edges.
  Where information originally stems from.

/ Yield:
  A vertex without incoming edges.
  Where information originally stems from.

This allows gamification:
Given a set of roots,
find the smallest and easiest comprehensible yield
without sacrificing too much on accuracy.

As a side effect, if one isn't happy with the current yield,
one is never bound to it.
Either the yield itself can be modified,
or a new yield can be created with the current yield as basis.

= Application

The theoretical model is nice and all,
but most of the time I actually don't have it in my mind.
Instead, at the bottom of a note
is usually a section `References` or `Resources`
where I put all links, talks and notes this is an effect of into
without thinking too much of them as roots.

