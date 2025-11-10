## Benchmarking (Video 35)
- Go has standard tools for testing (`go test`), and benchmarks live in `_test.go` files
- `go test -bench` will only run `BenchmarkXXX` functions
- When benchmarking, you have a `*testing.B`

```go
func BenchmarkSomeFunc(b *testing.B) {
    for n := 0; n < b.N; n++ {
        // do your work in here
    }
}
```

- Go will figure out how many iterations it can run in one second
  - It will run the test function many times, increasing b.N until it hits the `-benchtime` (default 1s), with some safeguards
  - Then it will calculate statistics on execution

### List Example
```go
type node struct {
    v int
    t *node
}

// simple linked list example - insert new value into list
func insert(i int, h *node) *node {
    t := &node{i, nil}

    if h != nil {
        h.t = t
    }

    return t
}

// make a new linked list of a given size
func mkList(n int) *node {
    var h, t *node

    h = insert(0, h) // make first head node
    t = insert(1, h) // add first tail node

    for i := 2; i < n; i++ {
        // add new tail node and update value
        t = insert(i, t)
    }

    return h
}

// sum all values in a list - walk down the list
// uses nice named return value syntax
func sumList(n *node) (i int) {
    for n := h; n != nil; n = n.t {
        i += h.v
    }
    return
}

// make a new slice 
func mkSlice(n int) []int {
    r := make([]int, n)

    for i := 0; i < n; i++ {
        r[i] = i
    }

    return r
}

func sumSlice(l []int) (i int) {
    for _, v := range l {
        i += v
    }
    return
}
```

- The above example shows two implementations of creating and summing over a list of elements, firstly using a linked list, then using a slice
- We can write a benchmark function as follows:

```go
func BenchmarkList(b *testing.B) {
    // note how we create the list before starting the benchmark. this kind of setup may or may not be useful to include
    // in the benchmarking
    l := mkList(1200)
    b.ResetTimer()
    for n := 0; n < b.N; n++ {
        sumList(l)
    }
}

func BenchmarkSlice(b *testing.B) {
    l := makeSlice(1200)
    b.ResetTimer()
    for n := 0; n < b.N; n++ {
        sumSlice(l)
    }
}
```

- Where we observe the difference between performance:

```yaml
goos: darwin
goarch: arm64
pkg: 0x416c6578/goplayground/testing
cpu: Apple M2 Pro
BenchmarkList
BenchmarkList-10     	 1103652	      1056 ns/op
BenchmarkSlice
BenchmarkSlice-10    	 3315700	       359.3 ns/op
PASS
``` 

- The slice is a lot faster since the memory access patterns favour cache a lot more than the linked list
- We can also do an allocation benchmark to see how many allocations are required for each:

```yaml
goos: darwin
goarch: arm64
cpu: Apple M2 Pro
BenchmarkList-10           64849             15817 ns/op           19200 B/op       1200 allocs/op
BenchmarkSlice-10        1537908               776.1 ns/op             0 B/op          0 allocs/op
PASS
```

- The slice has 0 allocations 🤔
  - This is because escape analysis means that slice gets allocated on the stack and so there are zero memory allocations!
  - I found you can make it allocate in two ways, either by increasing the size of the slice to something beyond Go's limit for escaping (I found > 10000 seemed to work), or assigning the created slice to a package level variable (global)

### Dynamic Dispatch Example
```go
const defaultChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

func randString(length int, charset string) string {
	b := make([]byte, length)

	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}

	return string(b)
}

type forwarder interface {
	forward(string) int
}

type thing1 struct {
	t forwarder
}

func (t1 *thing1) forward(s string) int {
	return t1.t.forward(s)
}

type thing2 struct {
	t forwarder
}

func (t2 *thing2) forward(s string) int {
	return t2.t.forward(s)
}

type thing3 struct {
}

func (t3 *thing3) forward(s string) int {
	return len(s)
}

func length(s string) int {
	return len(s)
}

func BenchmarkDirect(b *testing.B) {
	r := randString(rand.Intn(24), defaultChars)
	h := make([]int, b.N)

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		h[i] = length(r)
	}
}

func BenchmarkForward(b *testing.B) {
	r := randString(rand.Intn(24), defaultChars)
	h := make([]int, b.N)

    // we create a chain of these interfaces that are forwarding their method calls
	var t3 forwarder = &thing3{}
	var t2 forwarder = &thing2{t3}
	var t1 forwarder = &thing1{t2}

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		h[i] = t1.forward(r)
	}
}
```

```yaml
goos: darwin
goarch: arm64
cpu: Apple M2 Pro
BenchmarkDirect-10      1000000000               1.094 ns/op           0 B/op          0 allocs/op
BenchmarkForward-10     597470830                2.031 ns/op           0 B/op          0 allocs/op
PASS
```

- We can see how the direct function call is basically twice as fast as the direct dispatch / forwarded call which goes through several layers of abstraction

### False Sharing Example
- Won't copy the code, but the video explains an example of where many Goroutines are attempting to write to different variables which exist on the same cache line
- This causes contention and false sharing behaviour, limiting the performance of the program
- The fix for the artificial example was to have a local variable used for the running count, then only storing the result to that variable on the shared cache line once, thus reducing contention and speeding things up
- This is a very good video series (:
