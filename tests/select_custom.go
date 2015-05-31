package main

func f() int {
	return 1
}

func main() {
	var c1 = make(chan int, 1)
	var c2 = make(chan int, 1)
	var c3 = make(chan int, 1)
	var c4 = make(chan int, 1)
	var c5 = make(chan int, 1)
	var c6 = make(chan int, 1)
	var i2, i3, i6 int
	var ok3 bool
	var l = make([]int, 2)

	c1 <- 1
	c2 <- 2
	c3 <- 3
	c4 <- 4
	c5 <- 5
	c6 <- 6

LOOP:
	for {
		select {
		case <-c1:
		case i2 = <-c2:
		case i3, ok3 = <-c3:
		case l[0] = <-c4:
		case l[f()] = <-c5:
		case i6 = <-c6:
		default:
			break LOOP
		}
	}
	// println(i2, i3, ok3, l[0], l[1], i6)
	if i2 != 2 {
		println("i2:", i2, "!=", 2)
		panic("fail")
	}
	if i3 != 3 {
		println("i3:", i3, "!=", 3)
		panic("fail")
	}
	if ok3 != true {
		println("ok3:", ok3, "!=", true)
		panic("fail")
	}
	if l[0] != 4 {
		println("i4:", l[0], "!=", 4)
		panic("fail")
	}
	if l[1] != 5 {
		println("i5:", l[1], "!=", 5)
		panic("fail")
	}
	if i6 != 6 {
		println("i6:", i6, "!=", 6)
		panic("fail")
	}
}
