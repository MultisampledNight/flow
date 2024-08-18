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

// Instruction to the `trans` function that a certain tree part has to be handled differently.
// The `queue` is the tree part to be placed under the modifier,
// the `cfg` specifies additional arguments for the `trans` function.
#let _modifier(queue, cfg) = (queue: queue, cfg: cfg)
#let _is-modifier(part) = (
  type(part) == dictionary and
  "queue" in part and
  "cfg" in part
)

// Create a new branch. After all coordinates in this branch have been processed,
// return to the node before it.
// At the end of a branch, an arrow mark is always placed.
// TODO: implement in trans
#let br(..args) = _modifier(args.pos(), (branch: true))

// Label the edges created in this call.
// The label is:
//
// - Only drawn once, after all edges and states have been drawn.
// - Placed in the center of all states in this call.
// TODO: implement in trans
#let tag(..args, tag: none) = _modifier(args.pos(), (tag: tag))

// Offsets drawn edges so that they can be drawn next to each other at different offsets
// while still being distinguishable.
//
// This allows drawing states
// with multiple inputs and outputs
// on the same edge
// more easily.
//
// Leaning with an amount of 0 is equivalent to not leaning at all,
// and just passing all states at their center.
//
// TODO: implement in trans
#let lean(..args, amount: 0.25em) = _modifier(args.pos(), (lean: amount))

// Style all edges inside this call.
// Use named arguments for doing so, just like any other cetz element.
// Styles can be stacked and will be merged, with deeper styles taking precedence.
//
// The function is suffixed with `d`
// to avoid shadowing the builtin Typst `style` function.
#let styled(..args) = _modifier(args.pos(), (styles: args.named()))

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
//
// At least, one starting state and a target state are needed.
// Afterwards, any number of branches can follow, and the default one is automatically entered.
// A branch is a sequence, where each element can be a coordinate or another branch.
// Coordinates can be specified in place.
// Branches are specified via the `br` function.
//
// Essentially, you can think of branches like save and restore points.
// Anytime you type `br(`, the current position in the tree is stored on a stack.
// Continuing to type more coordinates or branches after do not modify this stored entry.
// Typing a closing `)` of a `br` call pops the last position from the stack and
// continues from there.
// This can nest arbitrarily often.
#let trans(from, ..args) = {
  if args.pos().len() == 0 {
    panic("need at least one target state to transition to")
  }

  // essentially an "inverse" depth first search
  // we already have the tree and the search we want to follow
  // we just need to repeat it along the plan

  // basically manual recursion. each array entry is a stack frame
  // each stack frame has a field `queue` for the coords/branches to next run through
  // additionally each frame can be a *modifier* — that is, specially influencing processing somehow
  // see the functions above calling _modifier for an explanation
  let depth = ((queue: args.pos().rev(), cfg: (:)),)
  let last = from

  while depth.len() != 0 {
    let queue = depth.last().queue

    // has this frame has been fully processed?
    if queue.len() == 0 {
      // if we should reset due to branching, do so
      let frame = depth.pop()

      if frame.cfg.at("branch", default: false) {
        last = frame.last
      }

      // TODO: draw label between `part` and `last` if the frame was a `tag` one?

      continue
    }

    let part = queue.pop()
    depth.last().queue = queue

    if _is-modifier(part) {
      // advance in depth
      // can just make it a new frame
      // some modifiers (e.g. branch, tag) need the last node,
      // so store that one, too
      part.last = last
      depth.push(part)

      continue
    }

    // then let's get to drawing!
    // go through all modifiers we have atm, stack them and then draw them
    let styles = depth
      .filter(frame => "styles" in frame.cfg)
      .map(frame => frame.cfg.styles)
      .join()

    let current = part
    line(last, current, ..styles)

    // TODO: if the last one, draw arrowhead or label
  }
}
