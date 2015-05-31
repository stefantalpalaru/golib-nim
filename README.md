##description

[Nim language][1] bindings for [golib][2] - a library that (ab)uses gccgo to bring Go's channels and goroutines to the rest of the world.

##syntax comparison

| feature | Go | Nim |
|---------|----|-----|
| channel type <br> (here in a <br> function <br> parameter) | ``` func S(a, b chan uint) int { ``` | ``` proc S(a, b: chan[uint]): int = ``` |
| restricted <br> channel types | ``` chan<- float64 ``` <br> ``` <-chan int ``` | TODO |
| create channel | ``` c := make(chan int) ``` <br> ``` c2 := make(chan int, 1) ``` | ``` var c = make_chan(int) ``` <br> ``` var c2 = make_chan(int, 1) ``` |
| send value <br> to channel | ``` c <- 1 ``` | ``` c <- 1 ``` |
| receive value <br> from channel | ``` av := <-a ``` <br> ``` av, bv := <-a, <-b ``` <br> ``` cv, ok := <-c ``` | ``` var av = <-a ``` <br> ``` var (av, bv) = (<-a, <-b) ``` <br> ``` var (cv, ok) = <--c ``` |
| channel select | ``` select { ``` <br> ``` case c0 <- 0: ``` <br> ``` case <-c1: ``` <br> ``` case i2 = <-c2: ``` <br> ``` case i3, ok3 = <-c3: ``` <br> ``` case li[0] = <-c4: ``` <br> ``` case li[f()] = <-c5: ``` <br> ``` default: ``` <br> ``` break LOOP ``` <br> ``` } ``` | ``` select: ``` <br> ``` scase c0 <- 0: discard ``` <br> ``` scase <-c1: discard ``` <br> ``` scase (i2 = <-c2): discard ``` <br> ``` scase ((i3, ok3) = <--c3): discard ``` <br> ``` scase (li[0] = <-c4): discard ``` <br> ``` scase (li[f()] = <-c5): discard ``` <br> ``` default: ``` <br> ``` break LOOP ``` |
| declare goroutine | ``` func f(x, y int) { ``` <br> ``` println(x, y) ``` <br> ``` } ``` | ``` proc f(x, y: int) {.goroutine.} = ``` <br> ``` echo(x, " ", y) ``` |
| launch goroutine | ``` go f(1, 2) ``` | ``` go f(1, 2) ``` |
| non-blocking <br> sleep | ``` time.Sleep(100 * time.Millisecond) ``` | ``` go_sleep_ms(100) ``` |
| yield to another <br> goroutine | runtime.Gosched() | ``` go_yield() ``` |
| run the goroutines <br> on all the available <br> CPU cores | ``` runtime.GOMAXPROCS(runtime.NumCPU()) ``` | ``` runtime_gomaxprocsfunc( runtime_ncpu) ``` |
| special code <br> layout | | ``` import golib ``` <br><br> ``` proc go_main() {.gomain.} = ``` <br> ``` # main code here ``` <br><br> ``` golib_main() ``` <br> ``` # not reached ``` |
| compiler <br> parameters | | ``` # nim.cfg ``` <br> ``` --threads:on ``` <br> ``` --stackTrace:off ``` <br> ``` --passC:"--std=gnu99" ``` <br> ``` --dynlibOverride:"go" ``` <br> ``` --passL:"-lgolib -lgo" ``` <br> ``` --gc:go ``` <br> ``` # or --gc:none ``` |

##API stability

The API is subject to change until the first version (0.0.1) is released. After this, backwards compatibility will become a priority.

##requirements

- [golib][2]
- [a Nim fork with the Go GC][3] if you want garbage collection in Nim

##build the benchmark and run tests

```sh
./autogen.sh
```
If you have a Nim branch with the Go GC in ../Nim\_gogc/:
```sh
./configure NIM=../Nim_gogc/bin/nim
```
Or with vanilla Nim and no GC:
```sh
./configure --disable-gogc
```
Run tests:
```sh
make check
```
Benchmark (compare it with the ones from golib):
```sh
make
/usr/bin/time -v ./benchmarks/cw_nim
```

##install

```sh
nimble install
```

##license

BSD-2

##credits

- author: Ștefan Talpalaru <stefantalpalaru@yahoo.com>

- homepage: https://github.com/stefantalpalaru/golib-nim


[1]: http://nim-lang.org/
[2]: https://github.com/stefantalpalaru/golib
[3]: https://github.com/stefantalpalaru/Nim

