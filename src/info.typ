// Metadata info and the works.
// Also contains a typecheck machine for absolutely no reason
// other than being a cool sideproject and
// forcing myself to use strings instead of contents for e.g. content warnings.

#import "gfx/mod.typ" as gfx
#import "palette.typ": *
#import "tyck.typ"
#import "util/small.typ": maybe-do

// Panics if known typo'd metadata fields are contained.
#let _check-typos(it) = {
  let typos = (
    "alias": "aliases",
    "aliase": "aliases",
    "content-warning": "cw",
    "content-warnings": "cw",
  )

  for key in it.keys() {
    if key in typos.keys() {
      panic(
        "metadata key `"
          + key
          + "` passed to template, which is a typo. "
          + "use `"
          + typos.at(key)
          + "` instead.",
      )
    }
  }
}

// TODO: add function that goes through value and converts it into a schema using the functions above

#let _schema = {
  import tyck: *
  _attrs(
    aliases: _any(str, _array(str)),
    author: _any(str, _array(str)),
    cw: _any(str, _array(str)),
    tags: _any(str, _array(str)),
    translation: _dict(str, _any(str, _array(str))),
    keywords: _any(
      // shorthand for bolding all listed keywords
      _array(str),
      // the explicit version which allows using any function for modification
      _dict(str, function),
      // TODO: one day, implement auto which searches through all keywords
    ),
    lang: str,
  )
}

#let _check(it) = {
  _check-typos(it)
  tyck.validate(it, _schema)
}

// Puts some well-known metadata fields into an array if they stand alone.
// Returns the modified metadata.
#let _normalize(it) = {
  let arrayize = ("aliases", "author", "cw", "tags")

  for (name, data) in it {
    if type(data) != array and name in arrayize {
      it.at(name) = (data,)
    }
  }

  it
}

#let preprocess(it) = {
  _check(it)
  _normalize(it)
}

#let queryize(it) = [
  #metadata(it) <info>
]

/// Renders data in a best-effort pretty way. Returns opaque content.
/// Accepts dictionaries, lists, almost any data structure.
///
/// `ctx` is used for recursion, it is the most recent field key.
/// You can set it to denote the name this is in
/// for context but you don't need to.
#let render(data, name: none) = {
  if name != none and "cw" in lower(name) {
    par(leading: 1.5em, data.map(gfx.invert).join(h(0.5em)))
  } else if type(data) == array {
    // need to serialize each element, otherwise e.g. integers couldn't be joined
    data.map(render.with(name: name)).join[, ]
  } else if type(data) == dictionary {
    show: maybe-do(name != none, grid.cell.with(stroke: (
      left: (gamut.sample(20%)),
    )))

    grid(
      columns: 2,
      align: (right, left),
      inset: (x, y) => {
        if x == 0 {
          (right: 0.5em)
        } else {
          (left: 0.5em)
        }
      },
      row-gutter: 1em,
      ..data
        .pairs()
        .filter(((name, _)) => name not in ("keywords", "title"))
        .map(((name, data)) => (fade(name), render(data, name: name)))
        .join()
    )
  } else {
    // content/int/string/function
    [#data]
  }
}

