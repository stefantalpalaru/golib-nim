import golib

proc go_main() {.gomain.} =
    var c = make_chan(int, 1)
    c <- 100
    var (x, ok) = <--c
    if x != 100 or not ok:
        echo("x=", x, " ok=", ok, " want 100, true")
        quit("fail")
    close(c)
    var (x2, ok2) = <--c
    if x2 != 0 or ok2:
        echo("x=", x2, " ok=", ok2, " want 0, false")
        quit("fail")

golib_main()
# not reached

