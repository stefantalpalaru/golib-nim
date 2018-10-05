import golib

proc whisper(left, right: chan[int]) {.goroutine.} =
    left <- 1 + <-right

proc first_whisper(c: chan[int]) {.goroutine.} =
    c <- 1

proc go_main() {.gomain.} =
    runtime_gomaxprocsfunc(getproccount())

    const n = 500000
    var
        leftmost = make_chan(int)
        right = leftmost
        left = leftmost
    for i in 0..<n:
        right = make_chan(int)
        go whisper(left, right)
        left = right
    go first_whisper(right)
    echo(<-leftmost)

golib_main()
# not reached

