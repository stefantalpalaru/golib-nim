import golib

proc go_main() {.gomain.} =
    type
        Tp1 = tuple[i1: int32, p2: pointer]
        # Tp2 = tuple[i: int]
    var
        x: Tp1 = (1.int32, nil)
        # y: Tp2 = (2)

    echo(x.i1, " ", cast[int](x.p2))
    # echo(y.i)


golib_main()
# not reached

