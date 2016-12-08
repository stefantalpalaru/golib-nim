import golib


var
    c: chan[int]
    cr: recv_chan[int]
    cs: send_chan[int]

proc go_main() {.gomain.} =
    c = make_chan(int)
    cr = make_chan(int)
    cs = make_chan(int)
    cr = c  # ok
    cs = c  # ok
    static: doAssert compiles(<-cr)
    # static: doAssert(compiles(<-cs), "- some error")
    # static: doAssert(type(c) is chan or type(c) is recv_chan, "- the type must be 'chan' or 'recv_chan'")
    # c = cr  # ERROR "illegal types|incompatible|cannot"
    # c = cs  # ERROR "illegal types|incompatible|cannot"
    # cr = cs # ERROR "illegal types|incompatible|cannot"
    # cs = cr # ERROR "illegal types|incompatible|cannot"

    c <- 0 # ok
    <-c    # ok
    var (x, ok) = <--c    # ok
    var (a, b) = (x, ok)

    # cr <- 0 # ERROR "send"
    <-cr    # ok
    (x, ok) = <--cr    # ok
    (a, b) = (x, ok)

    cs <- 0 # ok
    # <-cs    # ERROR "receive"
    # (x, ok) = <--cs    # ERROR "receive"
    (a, b) = (x, ok)

    # static: doAssert(compiles(cs <- a), "- some error")
    select:
        scase c <- 0: discard # ok
        scase (x = <-c): # ok
            a = x

        # scase cr <- 0: discard # ERROR "send"
        scase (x = <-cr): # ok
            a = x

        scase cs <- 0: discard # ok
        # scase (x = <-cs): # ERROR "receive"
            # a = x

    for a in cr: discard
    # for a in cs: discard # ERROR "receive"

    close(c)
    close(cs)
    # close(cr)  # ERROR "receive"

golib_main()
# not reached

