##description

[Nim language][1] bindings for [golib][2] - a library that (ab)uses gccgo to bring Go's channels and goroutines to the rest of the world.

##syntax comparison

| feature | Go | Nim |
|---------|----|-----|
| create channel | ``` c := make(chan int) ``` <br> ``` c2 := make(chan int, 1) ``` | ``` var c = make_chan(int) ``` <br> ``` var c2 = make_chan(int, 1) ``` |
| send value <br> to channel | ``` c <- 1 ``` | ``` c <- 1 ``` |
| receive value <br> from channel | ``` av := <-a ``` <br> ``` av, bv := <-a, <-b ``` <br> ``` cv, ok := <-c ``` | ``` var av = <-a ``` <br> ``` var (av, bv) = (<-a, <-b) ``` <br> ``` var (cv, ok) = <--c ``` |
| channel type <br> (here in a function <br> parameter) | ``` func S(a, b chan uint) int { ``` | ``` proc S(a, b: chan[uint]): int = ``` |
| declare goroutine | ``` func f(x, y int) { ``` <br> ``` println(x, y) ``` <br> ``` } ``` | ``` proc f(x, y: int) {.goroutine.} = ``` <br> ``` echo(x, " ", y) ``` |
| launch goroutine | ``` go f(1, 2) ``` | ``` go f(1, 2) ``` |
| special code layout | | ``` import golib ``` <br><br> ``` proc go_main() {.gomain.} = ``` <br> ``` # main code here ``` <br><br> ``` golib_main() ``` <br> ``` # not reached ``` |
| compiler params | | ``` # nim.cfg ``` <br> ``` --threads:on ``` <br> ``` --stackTrace:off ``` <br> ``` --passC:"--std=gnu99" ``` <br> ``` --dynlibOverride:"go" ``` <br> ``` --passL:"-lgolib -lgo" ``` <br> ``` --gc:go ``` <br> ``` # or --gc:none ``` |


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

