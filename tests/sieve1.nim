import golib

# Send the sequence 2, 3, 4, ... to channel 'ch'.
proc Generate(ch: send_chan[int]) {.goroutine.} =
    var i = 2
    while true:
        ch <- i # Send 'i' to channel 'ch'.
        inc i

# Copy the values from channel 'in_ch' to channel 'out_ch',
# removing those divisible by 'prime'.
proc Filter(in_ch: recv_chan[int], out_ch: send_chan[int], prime: int) {.goroutine.} =
    for i in in_ch: # Loop over values received from 'in_ch'.
        if i mod prime != 0:
            out_ch <- i # Send 'i' to channel 'out'.

# The prime sieve: Daisy-chain Filter processes together.
proc Sieve(primes: send_chan[int]) {.goroutine.} =
    var ch = make_chan(int) # Create a new channel.
    go Generate(ch)      # Start Generate() as a subprocess.
    while true:
        # Note that ch is different on each iteration.
        var prime = <-ch
        primes <- prime
        var ch1 = make_chan(int)
        go Filter(ch, ch1, prime)
        ch = ch1

proc go_main() {.gomain.} =
    var primes = make_chan(int)
    go Sieve(primes)
    var a = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
    for i in 0 ..< len(a):
        var x = <-primes
        if x != a[i]:
            echo(x, " != ", a[i])
            quit("fail")

golib_main()
# not reached

