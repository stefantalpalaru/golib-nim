discard """
  outputsub: "true"
"""

import golib
from strutils import join

type
  TFoo * = object
    id: int
    fn: proc(){.closure.}
var foo_counter = 0
# var alive_foos = newseq[int](0)
var alive_foos: seq[int]

proc free*(some: ref TFoo) =
  #echo "Tfoo #", some.id, " freed"
  alive_foos.del alive_foos.find(some.id)
proc newFoo*(): ref TFoo =
  new result, free

  result.id = foo_counter
  alive_foos.add result.id
  inc foo_counter

proc go_main() {.gomain.} =
    alive_foos = @[]

    for i in 0 ..< 10:
     discard newFoo()

    for i in 0 ..< 10:
      let f = newFoo()
      f.fn = proc =
        echo f.id

    GC_fullcollect()
    echo alive_foos.len <= 3

golib_main()
# not reached

