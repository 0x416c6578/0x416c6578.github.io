## More on Interfaces (Video 20)
- Interface variables are `nil` until initialised
- Nil interfaces have a slightly more complex structure than nil structs and values
- Nil interfaces have two parts
  - A value or pointer of some concrete type
  - A pointer to type information so the correct concrete implementation of the method can be identified
- We can picture this as `(type, ptr)`
- An interface is only `nil` when it's value is `(nil, nil)`

```go
var r io.Reader // nil interface here
var b *bytes.Buffer // nil value here

r = b // at this point r is no longer nil itself, but it has a nil pointer to a buffer
```

- When we assign `r = b` the new value of r is `(bytes.Buffer, nil)`

### The Error Interface

```go
type error interface {
  func Error() string
}
```

- `error` is an interface that has one method `Error()`
- Therefore we can if `err == nil` to see if the err return value was assigned - this is the idiomatic error checking mechanism in Go
- Because of this nil behaviour, we must NEVER RETURN A CONCRETE ERROR TYPE FROM A FUNCTION OR METHOD:

```go
type someErr struct {
  err error
  someField string
}

func (e someErr) Error() string {
  return "this is some error"
}

func someFunc(a int) *someErr { // We should NEVER return a concrete error type
  return nil
}

func main() {
  var err error = someFunc(123456)

  if err != nil {
    // Even though we logically didn't want to throw an error, returning a concrete error type 
    // meant that the err variable was initialised and looks like (*someErr, nil) which in the
    // semantics of interfaces ISN'T NIL
    fmt.Println("Oops")
  } else {
    // If we'd done err := someFunc(123456), the above check would have worked although again we 
    // should never return a concrete error implementation from a function
  }
}
```

- Again we should **never return a concrete error type from a function**
- In the above case, someFunc returns a nil pointer to a concrete value which gets copied into an interface, making the check `err != nil` return true which is logically incorrect

### More on Pointer vs Value Receivers from Matt Holiday Vid
- In general if one method of a type takes a pointer receiver, then _all_ it's methods should take pointer receivers
- This isn't enforced by the compiler but it should always be the case
- Having a pointer receiver implies the values of that type aren't safe to copy, e.g. `Buffer` which has an embedded `[]byte` which isn't safe to copy since the underlying array is shared, and any type that embeds any sort of mutex or other synchronisation primitives that should never be copied

### Interfaces in Practice
1. Let _consumers_ define the interfaces; what minimal set of behaviours do they require
  - This lets the caller have maximum freedom to pass in whatever it wants so long as the interface contract is adhered to
2. Reuse standard interfaces wherever possible
3. Keep interface declarations as small as possible - bigger interfaces have weaker abstractions
  - The Unix file API is simple for a reason
4. Compose one method interfaces into larger interfaces (if needed)
5. Avoid coupling interfaces to particular types or implementations; interfaces should define abstract behaviour
6. Accept interfaces but return concrete types

### _Be liberal in what you accept, be conservative in what you return_
- This is the idea that you should put the least restriction on what parameters you accept; the minimal interface
- But you should avoid restricting the use of your return type
- Returning `*os.File` is less restrictive than `io.ReadWriteCloser` because files have other useful methods that a caller would want access to
- Returning the `error` interface however is an exception to this rule

### Empty Interfaces
- `interface{}` has no methods, therefore it is satisfied by anything
  - In newer versions of Go the type alias `type any interface{}` is defined by the standard library for ease of use
- This is used commonly by `fmt` for printing any type, and by other packages requiring similar behaviour
  - They will use reflection to determine the runtime type of the thing being passed into it

## Revisiting [*Understanding nil*](https://www.youtube.com/watch?v=ynoY2xz-F8s)
- Now that I've watched the Matt Holiday videos on these concepts I revisited this good conference talk on *understanding nil* to understand it with added context and knowledge

### Zero Values
- In Go, all types have a zero value
- For bools this is false, numbers is 0 and strings is the empty string
  - For structs, the zero value is just a struct with all of it's fields set to their zero values
- `nil` is the zero value for pointers, slices, maps, channels, functions and interfaces

### Nil
- Nil has no value!!!
- `nil` is **not a keyword in Go**, it is a predeclared identifier

### Understanding the Different Types of `nil`
**Pointers**
- The nil value of pointers is basically just a pointer that points to nothing

**Slices**
- Internally slices have a pointer to the underlying array, a length and a capacity
- The nil value of slices is basically a slice with no backing array; with a length and capacity of 0

**Maps, Channels and Functions**
- These are all pointers under the hood that points to the concrete implementation of these things
- Therefore the nil value of these is just a nil pointer

### Nil Interfaces
- Nil interfaces are the most interesting concept of `nil` in Go
- Interfaces internally are a tuple consisting of `(Concrete Type, Value)`
- The nil value of interfaces is `(nil, nil)`
- The subtlety of this comes in when we assign a nil value to an interface - at that point we have `(some concrete type, nil)` internally for whatever the assigned type is, and this is no longer `==nil`

```go
func bad1() error {
  var err *someConcreteError
  return err // We are returning (*someConcreteError, nil) which !=nil
}

func bad2() *someConcreteError {
  // We are returning a concrete pointer to an error which will pass ==nil, however
  // it is very bad practice because the second you wrap this pointer in the error
  // interface you will have the same problem as above
  return nil
}
```

- Basically you should **never return concrete error types**

### How is Nil Useful
#### Nil Pointers
- We can make a nil *pointer* useful, see the linked list sum example above (also applies to trees and other more complex data structures)

#### Nil Slices
- Nil *slices* are useful, their length and capacity will be 0 and we can range over one without any issues
  - The only (expected) exceptional behaviour is indexing a nil slice, which would expectedly panic
  - Importantly you can also append to a nil slice without issues, this is a useful property

#### Nil Slices
- Nil *maps* are useful, you can get their length, range over them without issues, and you can check if something is in a map (`v, ok := map[i]` -> `zeroVal(type of map value), false` for any key `i`). That means nil maps are perfectly valid read only empty maps
  - Again similar to slices the only exceptional behaviour occurs when trying to assign to a nil map
- Nil *channels* are also useful
  - Nil channels will block indefinitely on send and receive, this is a useful behaviour. For context the behaviour is the opposite on a *closed* channel - a closed channel will return `zero(t), false` with that false `ok` flag indicating the channel is closed
- Nil channels can be used to *switch off* a select case:

<figure>
<img loading="lazy" width="500" src="../../Images/go-tutorial/channelmerge.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">Nil channels example</figcaption>
</figure>

- This function merges two channels into one. When a channel closes, ok will be false and we set that channel to nil
  - This will effectively disable that select case since it will be blocking indefinitely
  - Of course when both are nil (after both are closed), the function will close the output channel and return

### Function Currying
- Since functions are first class in Go, you can curry functions as you'd expect

```go
func Add(a, b int) {
  return a+b
}

func main() {
  var addTo5 func(int) int = func (a int) int {
    return Add(5, a)
  }
}
```

#### Method Values
- Since methods are just syntactic sugar for a function with an additional receiver parameter, we can close a method over a receiver value:

```go
func (p Point) Distance(q Point) float64 {
  return math.Hypot(q.X-p.X, q.Y-p.Y)
}

func main() {
  p := Point{1,2}
  q := Point{4,6}

  distanceFromP := p.Distance // Here we close over the receiver value p, returning a curried function
}
```

- Because `Distance` is a value receiver method, the value of p is closed over when defining `distanceFromP`; this means that if you update `p`, these changes _won't_ be reflected in the `distanceFromP` calls; it will always return the distance to the point (1,2) because that value was captured when the method value was created
- If we change `Distance` to be a pointer receiver method, any changes to `p` _will_ be reflected in the method

## Notes From Homework #4
```go
type dollars float32

func (d dollars) String() string {
    return fmt.Sprintf("$%.2f", d)
}

type database map[string]dollars

func (db database) list(w http.ResponseWriter, req *http.Request) {
    for item, price := range db {
        fmt.Fprintf(w, "%s: %s\n", item, price)
    }
}

func main() {
    db := database{
        "shoes": 50,
        "socks": 5,
    }
    http.HandleFunc("/list", db.list)
    log.Fatal(http.ListenAndServe("localhost:8080", nil))
}
```

- The list handler is a method value that closes over the db
  - We are allowed to close over the value here because db is a map, and even though we'll copy the map descriptor here the underlying hashmap will be the same in the copy
- This code has race conditions that must be fixed; concurrency is the next class (: