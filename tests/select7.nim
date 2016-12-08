import golib


proc recv1(c: recv_chan[int]) {.goroutine.} =
    <-c

proc recv2(c: recv_chan[int]) {.goroutine.} =
    select:
        scase <-c:
            discard

proc recv3(c: recv_chan[int]) {.goroutine.} =
    var c2 = make_chan(int)
    select:
        scase <-c:
            discard
        scase <-c2:
            discard

proc send1(recv: goroutine_type) =
    var c = make_chan(int)
    go recv(c)
    go_yield()
    c <- 1

proc send2(recv: goroutine_type) =
    var c = make_chan(int)
    go recv(c)
    go_yield()
    select:
        scase c <- 1:
            discard

proc send3(recv: goroutine_type) =
    var c = make_chan(int)
    go recv(c)
    go_yield()
    var c2 = make_chan(int)
    select:
        scase c <- 1:
            discard
        scase c2 <- 1:
            discard

proc go_main() {.gomain.} =
    send1(recv1)
    send2(recv1)
    send3(recv1)
    send1(recv2)
    send2(recv2)
    send3(recv2)
    send1(recv3)
    send2(recv3)
    send3(recv3)


golib_main()
# not reached

