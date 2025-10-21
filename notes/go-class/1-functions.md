## Functions (Video 8)
- Functions in Go are first class objects
- Almost anything can be defined in a function, except (understandably) methods
- The signature of a function is the order and type of its parameters and return values. Functions are always typed with structural typing rather than named typing

### Parameter Passing
- Numbers, bools, arrays and structs are passed by value
  - This is important to note since structs are the most likely things needing to be modified by a function or method
- Things passed by pointer (`&x`), strings (although they're immutable) slices, maps and channels are all passed by reference, meaning that their values can be updated inside a function 
- In actuality the model is similar to Java where it is technically all by value (except the value for those above things passed by _reference_ is the value of the _descriptor_ for that thing)
- This means that parameter reassignments for a non-pointer argument won't change the thing outside of the context of that function (but passing in a pointer to the function does mean we can reassign to the parameter and change the thing outside of the scope of the function). Basically the semantics are similar to Java

### Multiple Return Values
- Functions can return multiple return values by putting them in parens, e.g. `(int, error)`
- An idiomatic pattern is to return `(value, error)` where `error != nil` indicates some error has occurred

### Naked Return Values
- If you name the return value in the signature of your function, Go will implicitly declare variable(s) with the given names and types 

### Defer
- The defer statement allows you to defer some operation (function call) to run on function exit
- Care needs to be taken to make sure the defer makes sense and is valid
- Defer operates on a function scope, e.g.:

```go
func main() {
  f := os.Stdin

  if len(os.Args) > 1 {
    if f, err := os.Open(os.Args[1]); err != nil {
      ...
    }
    defer f.close()
  }

  // At this point we can do something with the file and only if it is a file passed in the params will it be closed at function exit
}
```

- The above example has `f.close()` running at _function_ exit not block ending
- The value of arguments in a deferred function call are _copied_ at the point of the defer call

```go
func thing() {
  a := 10
  defer fmt.Println(a)
  a = 11
  fmt.Println(a)
  // Will print 11,10
}
```
