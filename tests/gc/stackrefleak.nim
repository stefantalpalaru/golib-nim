discard """
  outputsub: "no leak: "
"""

import golib

type
  Cyclic = object
    sibling: PCyclic
    data: array[0..200, char]

  PCyclic = ref Cyclic

proc makePair: PCyclic =
  new(result)
  new(result.sibling)
  result.sibling.sibling = result

proc go_main() {.gomain.} =
  for i in 0..10000:
    var x = makePair()
    GC_fullCollect()
    x = nil
    GC_fullCollect()

  if getOccupiedMem() > 400_000:
    echo "still a leak! ", getOccupiedMem()
    quit(1)
  else:
    echo "no leak: ", getOccupiedMem()


golib_main()
# not reached

