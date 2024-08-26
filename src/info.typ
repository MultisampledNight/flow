// Metadata info and the works.
// Also contains a typecheck machine for absolutely no reason
// other than being a cool sideproject and
// forcing myself to use strings instead of contents for e.g. content warnings.

#import "palette.typ": *
#import "gfx.typ"

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
        "metadata key `" + key + "` passed to template, which is a typo. "
        + "use `" + typos.at(key) + "` instead."
      )
    }
  }
}

// <3
// Ordered sequence of elements of type `ty`.
#let _array(ty) = (array: (ty: ty))

// Key-value mapping ordered by insertion timepoint.
// Technically the key check is redundant
// since in Typst, dict keys are guaranteed to be strings
// but eh, it fits my mental model better to specify it explicitly.
#let _dict(key, value) = {
  if key != str {
    panic("typst doesn't support non-string dictionary keys")
  }
  (dict: (key: key, value: value))
}

// Key-value mapping with specifically defined keys.
// May contain more keys than specified which are ignored.
// Effectively a very lenient product type.
#let _attrs(..args) = (attrs: args.named())

// If any of the specified types match, the value is valid,
// regardless of any other matching.
// TODO: implement
#let _any(..args) = (any: args.pos())

// TODO: add formatting function and use it in the error report
// TODO: add function that goes through value and converts it into a schema using the functions above

#let _schema = _attrs(
  aliases: _array(str),
  cw: _array(str),
  tags: _array(str),
  lang: str,
)

// Checks if the given value adheres to the given expected type schema.
// The type schema needs to be constructed using the functions above.
// For collections, you should use the functions above.
// For primitives like `int` and `str`, you can just specify the types directly.
// (You can also specify `dictionary` for example, but that does not put any restrictions on the keys or values.)
//
// This is more specific than just comparing `type`
// since it also allows specifying the types of elements in collections.
// Returns a dictionary with the keys `expected`, `found`
// optionally `key` and `original`
// if the typecheck fails,
// otherwise returns none.
#let _typecheck(value, expected) = {
  // to have the typecheck work with nested collections,
  // we just rely on recursion
  // i despise the Go-ish error handling here but there are no usable alternatives here

  let actual = type(value)

  if actual == expected {
    return none
  }

  if actual == array {
    if type(expected) != dictionary or "array" not in expected {
      return (expected: expected, found: value)
    }

    for ele in value {
      let err = _typecheck(ele, expected.array.ty)
      if err != none {
        return (
          expected: expected.array.ty,
          found: ele,
          original: err,
        )
      }
    }
  } else if actual == dictionary {
    // was `expected` constructed using the functions above?
    if type(expected) != dictionary {
      return (expected: expected, found: value)
    }

    if "attrs" in expected {
      for (key, value) in value {
        let expected = expected.attrs.at(key, default: none)
        if expected == none {
          continue
        }

        let err = _typecheck(value, expected)
        if err != none {
          return (
            expected: expected,
            found: value,
            key: key,
            original: err,
          )
        }
      }
    } else if "dict" in expected {
      for (key, value) in value {
        let err = _typecheck(value, expected.dict.value)
        if err != none {
          return (
            expected: expected.dict.value,
            found: value,
            key: key,
            original: err,
          )
        }
      }
    }
  } else {
    return (
      expected: expected,
      found: value,
    )
  }
}

// Panics if known fields do not contain their known types.
#let _check-schema(it) = {
  let err = _typecheck(it, _schema)
  if err == none {
    return
  }

  panic(
    "metadata passed to template failed typecheck"
    + if "key" in err {
      " at key `" + err.key + "`"
    }
    + ". "
    + "expected: `" + repr(err.expected) + "`, "
    + "actual: `" + repr(type(err.found)) + "`"
  )
}

#let _check(it) = {
  _check-typos(it)
  _check-schema(it)
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
  #metadata(it) <info>
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