## Reflection (Video 33)
### `interface{}`
- The empty interface has no methods, and so it can represent anything
- It is a generic thing, but we sometimes need to downcast it to a real type
- Go has first class support for reflection

```go
var w io.Writer = os.Stdout
f := w.(*os.File) // success
c := w.(*bytes.Buffer) // failure since the interface holds a *os.File not a *bytes.Buffer
```

- Above shows an example of downcasting an interface to a specific type
- Downcasting comes from inheritance hierarchies, and in the context of Go might not be the correct term, instead *type assertion* is more correct
- There is also a two argument version that will return true or false for success or failure, rather than panicking as the above example would do

```go
c, ok := w.(*bytes.Buffer)
```

- Reflection is used a lot in the standard library, for example in `fmt` and `json`

```go
func Println(args ...interface{}) {
    // ...
    for arg := range args {
        switch a := arg.(type) {
            case string: // concrete type
                // do something with the string
            case Stringer: // interface
                // call the String() method on the interface to get the string representation
        }
    }
}
```

- The above example shows using reflection to switch on type. `a` takes on a value of the type it is, and when the case matches, a will have that corresponding type, meaning we can do things like call the methods on that `Stringer` interface

### DeepEqual
- In Go, slices can't be directly compared with `==`
- If we have a struct with an embedded slice, we can use `reflect.DeepEqual` to do a reflection based equals that will look into slices and other normally non-comparable structures to check for equality

```go
want := struct{
    someSlice := []int{1,2,3}
}

got := someFunction()

if !reflect.DeepEqual(got, want) {
    fmt.Println("failed equality check")
}
```
