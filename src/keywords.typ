#import "cfg.typ": render
#import "util.typ": swap-kv

#let char-that-does-nothing = "\u{200B}"
#let do-not-process(it) = {
  // this is a hack to make sure other show rules do not process the same `it`
  // but it works
  it.text.at(0)
  char-that-does-nothing
  it.text.slice(1)
}
/// Regex alternates.
#let any(..vars) = {
  "("
  vars.pos().join("|")
  ")"
}

// these below need to be kept in sync
// they are forward/backward for looking up in text vs. looking up their effect

/// Maps from canonical suffix to other possible suffices.
#let suffices = (
  // define → defining
  "e": "ing",
  // vertex → vertics
  // latex → latexes
  "ex": "(ices|exes)",
  // party → parties
  "y": "ies",
  // build → building
  // concept → conceptize
  // table → tables
  "": any("ing", "ize", "s"),
)
// FIXME: can't handle same alternates for different canonical suffices
// would actually need to be a... multimap?
#let suffices-rev = swap-kv(suffices)

/// Returns an array of possibile normalized forms of `it`.
#let normalize(it) = {
  let it = lower(it)

  // do we need to canonicalize the suffix?
  let choices = suffices-rev
    .keys()
    .filter(alternates => it.ends-with(regex(alternates)))
    .map(alternates => {
      let canonical = suffices-rev.at(alternates)
      it.trim(regex(alternates), at: end, repeat: false)
      canonical
    })

  if choices == () {
    (it,)
  } else {
    choices
  }
}

#let expand(it) = {
  let it = lower(it)
  // make it irrelevant if the first character is uppercase or lowercase
  let prefix = any(it.at(0), upper(it.at(0)))
  let rest = it.slice(1)

  // are there other possible suffices we need to account for?
  let suffix = suffices
    .keys()
    .find(canonical => it.ends-with(canonical))
  let rest = if suffix == none {
    rest
  } else {
    let alternates = suffices.at(suffix)

    rest.trim(suffix, at: end, repeat: false)
    any(suffix, alternates)
  }

  prefix + rest
}

// Constructs a regex that matches any entry in the `keywords` array,
// even if they are e.g. pluralized or conjugated.
#let construct-picker(keywords) = regex({
  "\b"
  any(..keywords.map(expand))
  "\b"
})

// Finds the appropriate operation for the given keyword and applies it.
#let apply-one(selected, registered) = {
  let original = normalize(selected.text)
    .filter(possibility => possibility in registered)
    .at(0, default: none)
  if original == none {
    panic({
      "could not match keyword in text to original: "
      "matched: `" + selected.text + "`, "
      "registered: [" + registered.keys().join(", ") + "]"
    })
  }
  let effect = registered.at(original)

  let op = if type(effect) == function {
    effect
  } else if type(effect) == color {
    text.with(fill: effect)
  } else if type(effect) == label {
    link.with(effect)
  }

  op(selected)
}

#let process(body, cfg: none) = {
  if cfg == none or not render {
    // no words to highlight → nothing to do!
    return body
  }

  // see the schema in src/info.typ for possible types cfg can have
  if type(cfg) == array {
    let converted = (:)
    for word in cfg {
      converted.insert(word, strong)
    }
    cfg = converted
  }

  // normalize all keys so the lookup normalization can find something
  for (word, op) in cfg {
    let _ = cfg.remove(word)
    cfg.insert(normalize(word).first(), op)
  }

  // then actually run through
  let picker = construct-picker(cfg.keys())

  // skip codeblocks
  show raw: it => {
    show picker: do-not-process
    it
  }
  // but do apply to everything else
  show picker: it => apply-one(it, cfg)

  body
}

