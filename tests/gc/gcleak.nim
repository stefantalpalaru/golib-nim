discard """
  outputsub: "no leak: "
"""

import golib

when defined(GC_setMaxPause):
  GC_setMaxPause 2_000

type
  TTestObj = object of RootObj
    x: string

proc MakeObj(): TTestObj =
  result.x = "Hello"

proc go_main() {.gomain.} =
  # var max_mem = 0
  for i in 1 .. 1_000_000:
    when defined(gcMarkAndSweep) or defined(boehmgc) or defined(gogc):
      if i mod 3000 == 0:
        GC_fullcollect()
    var obj = MakeObj()
    if getOccupiedMem() > 400_000: quit("still a leak!")
    # if getOccupiedMem() > max_mem: max_mem = getOccupiedMem()
  # echo max_mem

  echo "no leak: ", getOccupiedMem()


golib_main()
# not reached

