##description

[Nim language][1] bindings for [golib][2] - a library that (ab)uses gccgo to bring Go's channels and goroutines to the rest of the world.

##syntax comparison

| feature | Go | Nim |
|---------|----|-----|
| create channel |
```go
c := make(chan int)
```
|
```nimrod
var c = make_chan(int)
```
|

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

##API stability

The API is subject to change until the first version (0.0.1) is released. After this, backwards compatibility will become a priority.

##license

BSD-2

##credits

- author: Ștefan Talpalaru <stefantalpalaru@yahoo.com>

- homepage: https://github.com/stefantalpalaru/golib-nim


[1]: http://nim-lang.org/
[2]: https://github.com/stefantalpalaru/golib
[3]: https://github.com/stefantalpalaru/Nim

