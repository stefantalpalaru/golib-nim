import golib

proc f(): int =
    return 1

proc go_main() {.gomain.} =
    var
        c1 = make_chan(int, 1)
        c2 = make_chan(int, 1)
        c3 = make_chan(int, 1)
        c4 = make_chan(int, 1)
        c5 = make_chan(int, 1)
        c6 = make_chan(int, 1)
        i2, i3, i6: int
        ok3: bool
        li: array[2, int]

    c1 <- 1
    c2 <- 2
    c3 <- 3
    c4 <- 4
    c5 <- 5
    c6 <- 6

    block LOOP:
        while true:
            select:
                scase <-c1: discard
                scase(i2 = <-c2): discard
                scase((i3, ok3) = <--c3): discard
                scase(li[0] = <-c4): discard
                scase(li[f()] = <-c5): discard
                scase(i6 = <-c6): discard
                default:
                    break LOOP
    # echo ($i2, " ", $i3, " ", $ok3, " ", $li[0], " ", $li[1], " ", $i6)
    if i2 != 2:
        echo("i2: ", i2, " != ", 2)
        quit("fail")
    if i3 != 3:
        echo("i3: ", i3, " != ", 3)
        quit("fail")
    if ok3 != true:
        echo("ok3: ", ok3, " != ", true)
        quit("fail")
    if li[0] != 4:
        echo("i4: ", li[0], " != ", 4)
        quit("fail")
    if li[1] != 5:
        echo("i5: ", li[1], " != ", 5)
        quit("fail")
    if i6 != 6:
        echo("i6: ", i6, " != ", 6)
        quit("fail")

golib_main()
# not reached

