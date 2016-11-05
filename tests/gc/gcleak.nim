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
    for i in 1 .. 1_000_000:
      when defined(gcMarkAndSweep):
        GC_fullcollect()
      var obj = MakeObj()
      if getOccupiedMem() > 300_000: quit("still a leak!")
    #  echo GC_getstatistics()

    echo "no leak: ", getOccupiedMem()


golib_main()
# not reached

