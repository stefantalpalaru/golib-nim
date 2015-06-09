discard """
  output: "true"
"""

import intsets, golib

type
  TMyObject = object
    id: int
  StrongObject = ref TMyObject
  WeakObject = object
    id: int
    data: ptr TMyObject

var
  gid: int # for id generation
  # valid = initIntSet()
  valid: IntSet

proc finalizer(x: StrongObject) =
  valid.excl(x.id)

proc create: StrongObject =
  new(result, finalizer)
  result.id = gid
  valid.incl(gid)
  inc gid

proc register(s: StrongObject): WeakObject =
  result.data = cast[ptr TMyObject](s)
  result.id = s.id

proc access(w: WeakObject): StrongObject =
  ## returns nil if the object doesn't exist anymore
  if valid.contains(w.id):
    result = cast[StrongObject](w.data)

proc go_main() {.gomain.} =
  valid = initIntSet()
  # valid is accidentally collected by the Go GC by the time valid.incl() is called in create()

  var s: seq[WeakObject]
  newSeq(s, 10_000)
  for i in 0 .. s.high:
    s[i] = register(create())
  # test that we have at least 80% unreachable weak objects by now:
  when defined(gcMarkAndSweep):
    GC_fullcollect()
  var unreachable = 0
  for i in 0 .. s.high:
    if access(s[i]) == nil: inc unreachable
  # echo unreachable > 8_000
  if unreachable > 8_000:
    echo("true")
  else:
    quit("false")


golib_main()
# not reached

