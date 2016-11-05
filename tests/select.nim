import golib

var
    counter: uint
    shift: uint

proc GetValue(): uint =
    inc counter
    return 1.uint shl shift

proc Send(aa, bb: chan[uint]): int =
    var
        (a, b) = (aa, bb)
        i: int

    block LOOP:
        while true:
            select:
                scase a <- GetValue():
                    inc i
                    a = nil
                scase b <- GetValue():
                    inc i
                    b = nil
                default:
                    break LOOP
            inc shift
    return i

proc go_main() {.gomain.} =
    var
        a = make_chan(uint, 1)
        b = make_chan(uint, 1)
    if (var v = Send(a, b); v != 2):
        echo("Send returned ", v, " != 2")
        quit("fail")
    if (var (av, bv) = (<-a, <-b); (av or bv) != 3):
        echo("bad values ", av, " ", bv)
        quit("fail")
    if (var v = Send(a, nil); v != 1):
        echo("Send returned ", v, " != 1")
        quit("fail")
    if counter != 10:
        echo("counter is ", counter, " != 10")
        quit("fail")

golib_main()
# not reached

