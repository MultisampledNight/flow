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

#let br(..args) = (branch: args.pos())
#let exchange(coord, other-accent: fg, offset: 0.25em) = (
  exchange: coord,
  cfg: (other-accent: other-accent, offset: offset)
)
#let styled(coord, ..args) = (coord: coord, styles: args.named())

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
#let trans(from, accent: fg, ..parts) = {
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

    // do we need to descend in depth or can just stay at this one?
    if _is-br(part) {
      // create a new stack frame remembering where to reset to
      let subbranch = part.branch

      depth.push((
        // remember, pop works LIFO
        queue: subbranch.rev(),
        reset-to: last,
      ))
    } else {
      let (coord, styles) = if _is-styled(part) {
        part
      } else {
        (part, (:))
      }

      let (coord, exchange) = if _is-exchange(coord) {
        (coord.exchange, coord.cfg)
      } else {
        (coord, none)
      }

      // just draw a casual line
      // also ensuring relative coordinates are aware of resets
      let coord = _make-concrete(coord, last)

      styles += parts.named()
      let set-accent(styles, accent) = {
        if "mark" in styles {
          styles.mark.fill = accent;
        }
        if "stroke" in styles {
          styles.stroke.paint = accent;
        } else {
          styles += (stroke: (paint: accent))
        }
        styles
      }
      styles = set-accent(styles, accent)
      if exchange != none {
        let cfg = exchange
        let offset-line(from, to, styles, ..args) = line(
          (from, cfg.offset, 90deg, to),
          (to, cfg.offset, -90deg, from),
          ..args,
          ..parts.named(),
          ..styles,
        )
        offset-line(last, coord, styles)
        offset-line(coord, last, set-accent(styles, cfg.other-accent))
      } else {
        line(
          last, coord,
          stroke: (paint: accent),
          // on the end of branches we want to draw arrows
          mark: if queue.len() == 0 {
            (end: ">", fill: accent)
          },
          ..parts.named(),
          ..styles,
        )
      }

      last = coord
    }
  }
}
