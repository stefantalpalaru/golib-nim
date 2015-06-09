discard """
  output: "success"
"""

import golib

import os, times

proc go_main() {.gomain.} =
  var i = 0
  for ii in 0..50_000:
    #while true:
    var t = getTime()
    var g = t.getGMTime()
    #echo isOnStack(addr g)
    
    if i mod 100 == 0:
      let om = getOccupiedMem()
      #echo "memory: ", om
      if om > 106_000: quit "leak"
     
    inc(i)
    sleep(1)

  echo "success"


golib_main()
# not reached

