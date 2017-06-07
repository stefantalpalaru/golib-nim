import golib, strutils

# proc f(c: send_chan[int]) {.goroutine.} =
    # go_sleep_ms(100)
    # c <- 1

{.push, hint[XDeclaredButNotUsed]: off.}
proc f(args_for_goroutine: pointer) {.cdecl.} =
    var (c, bogus_param_for_goroutine) = cast[ref tuple[c: chan[int], bogus_param_for_goroutine: pointer]](args_for_goroutine)[]
    go_sleep_ms(100)
    c <- 1
{.pop.}

proc go_main() {.gomain.} =
    # type
        # Tp1 = tuple[i1: int32, p2: pointer]
        # # Tp2 = tuple[i: int]
    # var
        # x: Tp1 = (1.int32, nil)
        # # y: Tp2 = (2)

    # echo(x.i1, " ", cast[int](x.p2))
    # # echo(y.i)

    var c = make_chan(int)

    # go f(c)
    var test2_nim_19_8_f_args_tuple_ref_for_goroutine: ref type((c, nil.pointer))
    new(test2_nim_19_8_f_args_tuple_ref_for_goroutine)
    test2_nim_19_8_f_args_tuple_ref_for_goroutine[] = (c, nil)
    go_go(f, test2_nim_19_8_f_args_tuple_ref_for_goroutine)

    echo "got $# from f()" % $(<-c)


golib_main()
# not reached

