#import "cfg.typ": render

#let char-that-does-nothing = "\u{200B}"
#let do-not-process(it) = {
  // this is a hack to make sure other show rules do not process the same `it`
  // but it works
  it.text.at(0)
  char-that-does-nothing
  it.text.slice(1)
}

// these below need to be kept in sync
// they are forward/backward for looking up in text vs. looking up their effect

#let norm-to-alt = (
  vertex: "vertices",
  condense: "condensing",
)
#let alt-to-norm = norm-to-alt.pairs().map(array.rev).to-dict()

#let normalize(it) = {
  let it = lower(it)
  let lookup = alt-to-norm.at(it, default: none)
  if lookup != none {
    return lookup
  }

  it.at(0)

  let suffix = it.slice(1)
  if suffix.ends-with("ies") {
    suffix.slice(0, -3)
    "y"
  } else {
    let trim = str.trim.with(at: end, repeat: false)
    trim(trim(suffix, "s"), "ing")
  }
}

#let expand(it) = {
  let it = lower(it)
  // make it irrelevant if the first character is uppercase or lowercase
  let prefix = {
    "("
    it.at(0)
    "|"
    upper(it.at(0))
    ")"
  }

  let suffix = if it in norm-to-alt {
    "("
    it.slice(1)
    "|"
    norm-to-alt.at(it).slice(1)
    ")"
  } else if it.ends-with("y") {
    it.slice(1, -1)
    "(y|ies)"
  } else {
    it.slice(1)
    "(s|ing)?"
  }

  prefix
  suffix
}

// Constructs a regex that matches any entry in the `keywords` array,
// even if their first characters are capitalized.
#let construct-picker(keywords) = regex({
  "\b("

  keywords
    .map(expand)
    .join("|")

  ")\b"
})

// Finds the appropriate operation for the given keyword and applies it.
#let apply-one(selected, registered) = {
  let original = normalize(selected.text)
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
    cfg.insert(normalize(word), op)
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

