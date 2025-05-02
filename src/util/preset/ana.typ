// Utils for mathematical analysis.
#import "../small.typ": *

/// Domain of a function.
#let (dom,) = ("dom",).map(math.op)
/// Variadic function.
#let fn(var) = $f(var_1, ..., var_n)$

/// Inverse function or preimage.
#let finv = $f^(-1)$

/// Window becoming ever smaller, usually infinitesimally small.
#let window = $epsilon.alt$

/// Various shorthands for sums.
#let (
  sk0n,
  sk0m,
  sk0p,
  sk1n,
  sk1m,
  sk1p,
  si0n,
  si0m,
  si0p,
  si1n,
  si1m,
  si1p,
) = cartesian-product(
  "ki".codepoints(),
  range(2),
  "nmp".codepoints(),
).map(((idx, start, end)) => $sum_(idx = start)^end$)
#let (skn, skm) = (sk1n, sk1m)

/// Can be both plus or minus.
#let pm = sym.plus.minus
/// Both negative and positive infinity.
#let pmoo = $plus.minus oo$

/// A polynomial, written out explicitly.
#let ply(
  /// The coefficient variables base.
  /// It is indexed for the value to use as multiplier.
  coeff: $alpha$,
  /// The parameter. It is taken to the power of the current index.
  param: $x$,
  /// The degree, aka the highest exponent of `param` in it.
  deg: $n$,
  /// If `long` is true, what to index `coeff` with and take `param` to the power of.
  idx: $i$,
  /// If to render with the middle section as well.
  long: false,
) = {
  let mid = if long { $... + coeff_idx param^idx + ...$ } else { $...$ }
  $coeff_0 + coeff_1 param + mid + coeff_deg param^deg$
}

/// A polynomial, written as sum. See `ply`.
#let plys(
  coeff: $alpha$,
  param: $x$,
  deg: $k$,
  idx: $i$,
) = {
  $sum^deg_(idx = 0) coeff_idx param^idx$
}

/// A series definition.
///
/// If you want to specify your own sequence expression,
/// pass it as positional argument,
/// which will override the default.
#let sri(
  idx: $k$,
  init: $1$,
  ..args,
) = {
  let expr = args.pos().at(0, default: $a_idx$)
  $sum_(idx = init)^oo expr$
}

