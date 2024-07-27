#import "palette.typ": *
#import "gfx.typ"

// Panics if known typo'd metadata fields are contained.
#let _check(it) = {
  let typos = (
    "alias": "aliases",
    "aliase": "aliases",
    "content-warning": "cw",
    "content-warnings": "cw",
  )

  for field in it.keys() {
    if field in typos.keys() {
      panic(
        "metadata field `" + field + "` passed to template, which is a typo. "
        + "use `" + typos.at(field) + "` instead.")
    }
  }
}

// Puts some well-known metadata fields into an array if they stand alone.
// Returns the modified metadata.
#let _normalize(it) = {
  let arrayize = ("aliases", "cw")

  for (name, data) in it {
    if type(data) != array and name in arrayize {
      it.at(name) = (data,)
    }
  }

  it
}

// Accepts a dictionary where
// the key denotes the metadata field name and
// the value its, well, actual data.
#let _render(it) = {
  let field(name, data) = {
    if "cw" in lower(name) {
      data.map(gfx.invert).join()
    } else if type(data) == array {
      data.intersperse[, ].join()
    } else {
      [#data]
    }
  }

  grid(
    columns: 2,
    align: (right, left),
    gutter: 1em,
    ..it
    .pairs()
    .map(
      ((name, data)) => (dim(name), field(name, data))
    )
    .join()
  )
}

#let _queryize(it) = [
  #metadata(it) <metainfo>
]

// Takes in a dictionary representing metadata,
// prepares and qolifies it,
// renders it in a nice visual table and
// makes it easily processable via the query system (under the `<metainfo>` tag).
#let process(it) = {
  _check(it)
  it = _normalize(it)

  _render(it)
  _queryize(it)
}
