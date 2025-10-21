## Odds & Ends (Video 31)
### Enumerated Types & Iota
- Go doesn't have built in support for enumerated types, instead you define a series of constants using the `iota` operator

```go
type shoe int
const (
  tennis shoe = iota
  dress
  sandal
  clog
)
```

- This is the same as ⍳ in APL
- We can ignore the first value of `iota` with an underscore (`_ = iota`)
- `iota` starts over in every new `const` block

### Varargs

```go
func sum(nums ...int) int {
  var total int
  for _, num := range nums {
    total += num
  }
  return total
}
```

- Obviously only the last argument in the list can be variable
- If you have a slice of things you want to pass into a varargs parameter, you can do this:

```go
s := []int{1,2,3,4}
fmt.Println(sum(s...))
```

- This will pass in elements of s as arguments
- `append()` takes a variable number of things to append to a slice, so if we do `s = append(s, s...)`, we append s to itself, creating a list of `[i for i in s, i for i in s]`

### Sized Integers
- `int` in Go is nominally 64 bits on 64 bit machines

```go
bool
string
int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr
byte // alias for uint8
rune // alias for int32
     // represents a Unicode code point
float32 float64
complex64 complex128
```

- From the Go docs: *The int, uint, and uintptr types are usually 32 bits wide on 32-bit systems and 64 bits wide on 64-bit systems. When you need an integer value you should use int unless you have a specific reason to use a sized or unsigned integer type.*
- There are many bitwise operators in Go that are useful, see docs for reference

### Goto
- Go has a `goto` statement, use with caution!