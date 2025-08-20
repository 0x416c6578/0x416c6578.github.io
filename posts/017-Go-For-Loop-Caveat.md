# Go 1.22 Loop Variable Semantics Change
Whilst learning Go I stumbled upon quite a subtle but important change that was made to loop variables in Go 1.22. This is probably common knowledge for the Go enthusiast but whilst learning it was definitely interesting to stumble upon.

### The Change
Starting in Go 1.22 each iteration of a for loop creates a new variable for the loop variable, whereas prior to that it would be one variable in memory that will be changed by the loop:

```go
func main() {
    things := make([]func(), 4)

    for i := 0; i < 4; i++ {
        things[i] = func() {
            fmt.Println(i)
        }
    }

    for _, thing := range things {
        thing()
    }
}
```

Prior to Go 1.22, this would print `4,4,4,4` (because the closures will capture the loop variable i and will all refer to the same memory address for i on the heap), whereas now it will print `0,1,2,3` since a new loop variable i is introduced on each loop.

### Another Example
```go
func main() {
    items := [][2]byte{ {1,2}, {3,4}, {5,6} }
    a := [][]byte{}

    for _, item := range items {
        a = append(a, item[:])
    }
}
```

- For Go `<1,22`, this would result in `a` being `{{5,6},{5,6},{5,6}}` whereas after that, due to the above change, you would get the correct expected value of `a` since a new loop variable is introduced each iteration