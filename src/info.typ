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
#let _any(..args) = (any: args.pos())

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
// Returns true if the value matches, returns false if it is different.
#let _typecheck(value, expected) = {
  // to have the typecheck work with nested collections,
  // we just rely on recursion

  let actual = type(value)

  if actual == expected {
    return true
  }

  if actual == array {
    if type(expected) != dictionary or "array" not in expected {
      return false
    }

    for ele in value {
      if not _typecheck(ele, expected.array.ty) {
        return false
      }
    }

    return true
  } else if actual == dictionary {
    // was `expected` constructed using the functions above?
    if type(expected) != dictionary {
      return false
    }

    if "attrs" in expected {
      for (key, value) in value {
        let expected-value = expected.attrs.at(key, default: none)
        if expected-value == none {
          continue
        }

        if not _typecheck(value, expected-value) {
          return false
        }
      }

      return true
    } else if "dict" in expected {
      for (key, value) in value {
        if (
          not _typecheck(key, expected.dict.key)
          or not _typecheck(value, expected.dict.value)
        ) {
          return false
        }
      }

      return true
    }
  }

  false
}

// Panics if known fields do not contain their known types.
#let _check-schema(it) = {
  if _typecheck(it, _schema) {
    return
  }

  panic(
    "metadata passed to template failed typecheck. " +
    "expected schema: `" + repr(_schema) + "`, " +
    "actual values: `" + repr(it) + "`"
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
