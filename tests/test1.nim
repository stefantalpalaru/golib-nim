import macros, golib

dumpTree:
    # proc f1() = discard
    # proc f2(args: pointer) = discard
    # proc f3(args: pointer) {.cdecl.} = discard
    # f4 = proc (args: pointer) {.cdecl.} = discard
    # proc f5(args: pointer) {.goroutine, noreturn.} =
        # discard
    # proc f5(args: pointer, args2: pointer) {.goroutine, noreturn.} =
        # discard
    # proc go_main() {.cdecl, codegenDecl: "$1 $2$3 __asm__ (\"main.main\");\n$1 $2$3".} =
        # discard
    # go_go(f5, 1, nil)
    # type f8_args_tuple = tuple[a: int32, b: int64, c: pointer]
    # proc f8(a: int32, b: int64, c: pointer) = discard
    # var (a, b, c) = cast[ref f8_args_tuple](args)[]
    # var f8_args: ref f8_args_tuple
    # var f8_args: ref type((int32(y), int64(100), pointer(nil)))
    # new(f8_args)
    # f8(int32(y), int64(100), nil)
    # f8_args[] = (int32(y), int64(100), nil)
    # f8(cast[pointer](f8_args))
    # proc whisper(left, right: ref Channel[int32]) {.goroutine.} = discard
    # type X = tuple[left, right: ref Channel[int32]]

    # select:
        # scase a <- GetValue():
            # inc i
            # a = nil
        # scase (i1 = <-c1):
            # echo(i1)
        # scase (i3, ok = <--c3):
            # echo i3, ok
        # default:
            # break LOOP

    # var
        # send1: ref uint
    # new(send1)
    # send1[] = GetValue()
    # var
        # select_cases = [
            # chan_select_case(dir: SELECT_DIR_SEND, chan: a.get_chan, send: send1),
            # chan_select_case(dir: SELECT_DIR_RECV, chan: c1.get_chan, send: nil),
            # chan_select_case(dir: SELECT_DIR_RECV, chan: c3.get_chan, send: nil),
            # chan_select_case(dir: SELECT_DIR_DEFAULT, chan: nil, send: nil),
            # ]
        # res = chan_select(addr select_cases[0], len(select_cases))

    # case res.chosen:
        # of 0:
            # inc i
            # a = nil
        # of 1:
            # i1 = cast[ptr uint](res.recv)[]
            # echo(i1)
        # of 2:
            # i3 = cast[ptr uint](res.recv)[]
            # ok = res.recv_ok
            # echo i3, ok
        # of 3:
            # break LOOP
        # else:
            # discard
    select:
        scase <-c1:
            discard
        scase (i2 = <-c2):
            discard
        scase ((i3, ok3) = <--c3):
            discard
        scase (li[0] = <-c4):
            discard
        scase (li[f()] = <-c5):
            discard
    
    i2 = cast[ptr type(i2)](res.recv)[]
    ok3 = res.recv_ok
    li[0] = cast[ptr type(li[0])](res.recv)[]
    li[f()] = cast[ptr type(li[f()])](res.recv)[]


proc f6(args: pointer): int =
    return 1

proc f7(a: int32, b: int64, c: pointer) {.goroutine.} =
    echo "in f7()"
    echo(a, " ", b, " ", cast[int](c))

# f8(a: int32, b: int64, c: pointer)
proc f8(args: pointer) =
    var (a, b, c) = cast[ref tuple[a: int32, b: int64, c: pointer]](args)[]
    echo "in f8()"
    echo(a, " ", b, " ", cast[int](c))

proc f9() {.goroutine.} =
    echo "in f9()"

proc go_main() {.gomain.} =
    var x: pointer
    discard f6(x)
    var y = 10

    var f8_args: ref type((int32(y), int64(100), pointer(nil)))
    new(f8_args)
    f8_args[] = (int32(y), int64(100), nil)
    # f8(cast[pointer](f8_args))
    f8(f8_args)

    go f7(y.int32, 100.int64, nil.pointer)
    go f9()
    go_sleep_ms(100)

    var c = make_chan(int, 1)
    echo c
    c <- 100
    var r = <-c
    echo r
    c = nil
    echo c

golib_main()
# not reached

