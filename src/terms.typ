#let char-that-does-nothing = "\u{200B}"
#let do-not-process(it) = (
  it.text.at(0) +
  char-that-does-nothing +
  it.text.slice(1)
)

#let process(body, cfg: none) = {
  if cfg == none {
    // no terms to highlight → nothing to do!
    return body
  }

  // see the schema in src/info.typ for possible types cfg can have
  if type(cfg) == array {
    cfg = (bold: cfg)
  }

  let subset = cfg.bold
  let picker = regex(
    "\b(" +
    subset
      .map(term =>
        "(" + term.at(0) +
        "|" + upper(term.at(0)) +
        ")" +
        term.slice(1)
      )
      .join("|") +
    ")\b"
  )

  show raw: it => {
    show picker: do-not-process
    it
  }
  show picker: strong

  body
}

