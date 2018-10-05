discard """
  outputsub: "no leak: "
"""

import golib

type
  TNode = object
    data: array[0..300, char]

  PNode = ref TNode

  TNodeArray = array[0..10, PNode]

  TArrayHolder = object
    sons: TNodeArray

proc nullify(a: var TNodeArray) =
  for i in 0..high(a):
    a[i] = nil

proc newArrayHolder: ref TArrayHolder =
  new result

  for i in 0..high(result.sons):
    new result.sons[i]

  nullify result.sons

proc go_main() {.gomain.} =
  for i in 0..10000:
    if i mod 2000 == 0:
      GC_fullcollect()
    discard newArrayHolder()

  if getOccupiedMem() > 300_000:
    echo "still a leak! ", getOccupiedMem()
    quit 1
  else:
    echo "no leak: ", getOccupiedMem()


golib_main()
# not reached

