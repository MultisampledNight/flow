// cetz.draw but with extra utilities which are not needed when not drawing on a canvas

#import "@preview/cetz:0.2.2"
#import cetz.draw: *

#import "../palette.typ": *

// Only uses the x component of the given coordinate.
#let hori(coord) = (coord, "|-", ())
// Only uses the y component of the given coordinate.
#let vert(coord) = (coord, "-|", ())

// Convert from Typst alignment to cetz directions.
#let to-anchor(it) = {
  if it == top {
    "north"
  } else if it == bottom {
    "south"
  } else if it == left {
    "west"
  } else if it == right {
    "east"
  }
}

// Returns a point according to the given value
// on the edge of the given object.
// `object` needs to be a string, the name of a drawn element.
#let lerp-edge(object, edge, value) = {
  // decide what bounds to use
  let ys = if edge.y == none {
    (top, bottom)
  } else {
    (edge.y,) * 2
  }
  let xs = if edge.x == none {
    (left, right)
  } else {
    (edge.x,) * 2
  }

  let point = xs.zip(ys).map(
    ((x, y)) => object +
    "." + to-anchor(y) +
    "-" + to-anchor(x)
  )
  point.insert(1, value)
  point
}
#let over(object, value) = lerp-edge(object, top, value)
#let under(object, value) = lerp-edge(object, bottom, value)
#let right-to(object, value) = lerp-edge(object, right, value)
#let left-to(object, value) = lerp-edge(object, left, value)

#let br(..args) = (queue: args.pos(), cfg: (branch: true))
#let tag(..args, tag: none) = (queue: args.pos(), cfg: (tag: tag))
#let exchange(..args, other-accent: fg, offset: 0.25em) = (
  queue: args.pos(),
  cfg: (other-accent: other-accent, offset: offset)
)
#let styled(..args) = (queue: args.pos(), cfg: (styled: args.named()))

#let _is-br(part) = type(part) == dictionary and "branch" in part
#let _is-exchange(part) = type(part) == dictionary and "exchange" in part
#let _is-styled(part) = type(part) == dictionary and "coord" in part and "styles" in part

// shallowly replaces () with last
#let _make-concrete(coord, last) = if type(coord) == array {
  coord.map(p => if p == () { last } else { p })
} else if type(coord) == dictionary {
  for (key, p) in coord {
    if p == () {
      coord.insert(key, last)
    }
  }
  if "rel" in coord and "to" not in coord {
    coord.to = last;
  }
  coord
} else {
  coord
}

// Creates an edge denoting transition away from a starting state,
// branching out arbitrarily.
// The syntax for branching is inspired by the IUPAC nomenclature of organic chemistry:
// https://en.wikipedia.org/wiki/IUPAC_nomenclature_of_organic_chemistry
// Only one initial starting point is needed.
// Afterwards, any number of branches can follow, and the default one is automatically entered.
// A branch is a sequence, where each element can be a coordinate or another branch.
// Coordinates can be specified in place.
// Branches are specified via the `br` function.
//
// Essentially, you can think of branches like save and restore points.
// Anytime you type `br(`, the current position in the tree is stored on a stack.
// Continuing to type more coordinates or branches after do not modify this stored entry.
// Typing a `)` pops the last position from the stack and continues from there.
// This can nest arbitrarily often.
#let trans(from, ..parts, accent: fg) = {
  if parts.pos().len() == 0 {
    panic("need at least one target state to transition to")
  }

  // essentially an "inverse" depth first search
  // we already have the tree and the search we want to follow
  // we just need to repeat it along the plan

  // basically manual recursion. each array entry is a stack frame
  // each stack frame has a field `queue` for the coords/branches to next run through
  // and every stack frame lower than the toplevel one has a field `reset-to` containing the position
  let depth = ((queue: parts.pos().rev(), reset-to: none),)
  let last = from

  content((0, 0), [#depth])

  while depth.len() != 0 {
    let queue = depth.last().queue
    if queue.len() == 0 {
      // oh, this frame has been fully processed already
      // if we can reset, do so, otherwise we're finished with rendering
      let frame = depth.pop()

      if frame.reset-to != none {
        last = frame.reset-to
      } else {
        break
      }

      continue
    }

    let part = queue.pop()
    depth.last().queue = queue

    // TODO: write this whole part again, this time using the depth
  }
}
