## Closures (Video 9)
- Scope is static - based on the structure of the source code
- Lifetime depends on the program execution (e.g. returning a reference from a function makes that value live outside of the function scope)
  - The variable will exist so long as a part of the program keeps a pointer to it
  - Go will do escape analysis to figure out the lifetime of a thing
- A closure is when a function inside another function closes over one or more local variables of the outer function:

```go
func fib() func() int {
  a, b := 0, 1

  return func() int {
    a, b = b, a+b
    return b 
  }
}

func main() {
  f := fib()

  for x := f(); x < 100; x = f() {
    fmt.Println(x) // Prints fibonacci numbers less than 100
  }
}
```

- The inner function will get a reference to the outer function's variables
  - This is IMPORTANT - the closure gets a _reference_ - watch out for this
- Those variables may have a longer than expected lifetime so long as there's a reference to the inner function
- The actual _closure_ is the concrete thing returned by calling `thing()` above - it is a function that returns an int alongside the environment containing references to the values a and b
- See [this post](../posts/017-Go-For-Loop-Caveat.md) for information on an important change in Go 1.22 that changes the semantics of for loops that differs from the information shown in the tutorial video