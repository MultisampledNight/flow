#import "cfg.typ"
#import "palette.typ": *

/// Full-width dimmed line.
/// Useful for a conceptual or logical split.
#let separator = line(
  length: 100%,
  stroke: gamut.sample(25%),
) + v(-0.5em)

/// Displays the given content highlighted and only when compiled in dev mode.
#let todo(it) = if cfg.dev {
  text(duality.green, emph(it))
}

/// Returns the given amount of samples on the unit range [0%, 100%].
/// The returned samples are an array of floats,
/// beginning with 0 and ending with 1 (if there is more than one item).
/// All samples are equally spaced.
#let quantify-unit-range(samples) = {
  range(samples)
    .map(i => i / (samples - 1))
    .map(x => x * 100%)
}

/// Maps the given strings linearly across the full width of the given colors.
/// Returns a dictionary with the strings as keys and their sampled colors as values.
/// Useful for feeding into `keywords`.
#let gradient-map(items, targets) = {
  let pos = quantify-unit-range(items.len())
  let targets = gradient.linear(..targets).samples(pos)
  items.zip(targets).to-dict()
}
