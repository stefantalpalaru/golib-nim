import golib

proc whisper(left, right: chan[int]) {.goroutine.} =
    left <- 1 + <-right

proc first_whisper(c: chan[int]) {.goroutine.} =
    c <- 1

proc go_main() {.gomain.} =
    ## a slowdown in this scenario for gccgo-4.9.2 but not for go-1.4.2
    # runtime_gomaxprocsfunc(runtime_ncpu)

    const n = 500000
    var
        leftmost = make_chan(int)
        right = leftmost
        left = leftmost
    for i in 0..(n - 1):
        right = make_chan(int)
        go whisper(left, right)
        left = right
    go first_whisper(right)
    echo(<-leftmost)

golib_main()
# not reached

