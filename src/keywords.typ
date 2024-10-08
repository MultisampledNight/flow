#import "cfg.typ": render

#let char-that-does-nothing = "\u{200B}"
#let do-not-process(it) = {
  // this is a hack to make sure other show rules do not process the same `it`
  // but it works
  it.text.at(0)
  char-that-does-nothing
  it.text.slice(1)
}

#let normalize(it) = {
  lower(it.at(0))
  it.slice(1)
}

// Constructs a regex that matches any entry in the `keywords` array,
// even if their first characters are capitalized.
#let construct-picker(keywords) = regex({
  "\b("

  keywords
    .map(word => {
      // make it irrelevant if the first character is uppercase or lowercase
      "("
      word.at(0)
      "|"
      upper(word.at(0))
      ")"

      word.slice(1)
    })
    .join("|")

  ")\b"
})

// Finds the appropriate operation for the given keyword and applies it.
#let apply-one(selected, registered) = {
  let original = normalize(selected.text)
  let op = registered.at(original)
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

