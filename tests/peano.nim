# Test that heavy recursion works. Simple torture test for
# segmented stacks: do math in unary by recursion.

import golib

type
    Number = ref object
        n: Number

# -------------------------------------
# Peano primitives

proc zero(): Number =
    return nil

proc is_zero(x: Number): bool =
    return x == nil

proc add1(x: Number): Number =
    var e: Number
    new(e)
    e.n = x
    return e

proc sub1(x: Number): Number =
    return x.n

proc add(x, y: Number): Number =
    if is_zero(y):
        return x

    return add(add1(x), sub1(y))

proc mul(x, y: Number): Number =
    if is_zero(x) or is_zero(y):
        return zero()

    return add(mul(x, sub1(y)), x)

proc fact(n: Number): Number =
    if is_zero(n):
        return add1(zero())

    return mul(fact(sub1(n)), n)

# -------------------------------------
# Helpers to generate/count Peano integers

proc gen(n: int): Number =
    if n > 0:
        return add1(gen(n - 1))

    return zero()

proc count(x: Number): int =
    if is_zero(x):
        return 0

    return count(sub1(x)) + 1

proc check(x: Number, expected: int) =
    var c = count(x)
    if c != expected:
        echo("error: found ", c, "; expected ", expected)
        quit("fail")

# -------------------------------------
# Test basic functionality

proc init() =
    check(zero(), 0)
    check(add1(zero()), 1)
    check(gen(10), 10)

    check(add(gen(3), zero()), 3)
    check(add(zero(), gen(4)), 4)
    check(add(gen(3), gen(4)), 7)

    check(mul(zero(), zero()), 0)
    check(mul(gen(3), zero()), 0)
    check(mul(zero(), gen(4)), 0)
    check(mul(gen(3), add1(zero())), 3)
    check(mul(add1(zero()), gen(4)), 4)
    check(mul(gen(3), gen(4)), 12)

    check(fact(zero()), 1)
    check(fact(add1(zero())), 1)
    check(fact(gen(5)), 120)

# -------------------------------------
# Factorial

var results = [
    1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800,
    39916800, 479001600,
]

proc go_main() {.gomain.} =
    init()
    for i in 0..9:
        if (var f = count(fact(gen(i))); f != results[i]):
            echo("FAIL: ", i, " !: ", f, " != ", results[i])
            quit(0)


golib_main()
# not reached

