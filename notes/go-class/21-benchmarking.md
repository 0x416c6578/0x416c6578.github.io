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
func makeSlice(n int) []int {
    r := make([]int, n)

    for i := 0; i < n; i++ {
        r[i] = i
    }

    return r
}
```

- TODO: Finish