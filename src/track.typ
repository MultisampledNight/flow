#import "tyck.typ"

#let schema = {
  import tyck: *

  let rrule = _attrs(
    count: _any(int),
    forever: true,
    delay: datetime,
    until: datetime,
  )

  let event = _attrs(
    summary: str,
    description: str,

    start: datetime,
    end: datetime,
    delta: datetime,

    location: str,

    participants: _array(str),
    responsible: str,

    repeat: _array(rrule),

    tags: _array(str),

    uid: str,
  )

  (rrule: rrule, event: event)
}

#let event(..args) = {
  let args = args.named()
  tyck.validate(args, schema.event)

  [#metadata(args) <event>]

  repr(args)
}
