## Error Handling (Video 32)
### Overview of Errors
- Most of the times, errors are just strings
- The error interface is the base interface for all errors

```go
type error interface {
  Error() string
}
```

- We can create some other types with the `Error()` method if we want to

```go
type errType int
const (
  _ errType = iota
  noHeader
  invalidBody
)
type SomeError struct {
  kind errType
  pos int
  err error // some other underlying error
}

// implement the Error method for our new error
func (e SomeError) Error() {
  switch e.kind {
  case noHeader {
    return "No header"
  }
  case invalidBody {
    return "Invalid body"
  }
  }
}

// we can define our own methods on our custom error, e.g. building an error with value
func (e SomeError) with(pos int) SomeError {
  e1 = e
  e1.pos = pos
  return e1
}

// a useful pattern is to define "prototype" errors that we can then adapt using methods like above, e.g.
var (
  HeaderMissing = SomeError{kind: noHeader}
  BodyMissing = SomeError{kind: invalidBody}
)

// then if we have an invalid body we can specify a position for the error using the adapter:
BodyMissing.with(105)
```

- These prototype errors and adapter methods are a bit cleaner than one large constructor

### Wrapped Errors
- It is useful to have wrapped errors, e.g. if you have multiple layers of errors happening
- You use `fmt.Errorf("This is the wrapped error: %w", someErr)` to create a wrapped error
- Then use `errors.Is(err, target error)` to see whether any error in err's tree matches the target
  - This uses reflection to determine whether the target error is part of the source error's chain
  - It compares error **variables**, NOT TYPES!!
- We define the `Is()` method for our custom error types that allows determination of whether the error is of a certain type
  - In `errors.Is()` the logic for checking this is `if x, ok := err.(interface{ Is(error) bool }); ok && x.Is(target) { return true }`

```go
func (e *SomeError) Is(t error) bool {
  castErr, ok := t.(*SomeError)
  if !ok {
    return false
  }
  // here we check the internal kind of that errType defined above
  return castErr.kind == e.kind
}
```

#### `errors.As()`
- This function looks for an error type not a value, and if one is found in the error chain, will assign it to the provided error pointer

```go
if audio, err = DecodeWaveFile(fn); err != nil {
  var e os.PathError

  if errors.As(err, &e) {
    // ... do something with e
  }
}
```

- In the above example, we have some custom error that we want to potentially extract an `os.PathError` from the chain of `err`
- Again `As()` has similar logic to `Is()`: `if x, ok := err.(interface{ As(any) bool }); ok && x.As(target) { return true }`
- We can define a custom `As()` method for our custom error similar to `Is` if we need that functionality, otherwise the library will just use reflection to determine the equality of types and set it

### Errors Philosophy
- There are two types of errors in programs
- One is a *normal* error that results from bad input or from external conditions (e.g. network issues, file not found, no disk space etc.). In Go these are represented by the `error` type, these should be handled by our program gracefully
- The other is an *abnormal* error, resulting from invalid program logic, for example nil pointers. These come from bugs in the program you're writing and in Go these are represented by using the `panic` function
- `panic` is always a last resort and is a fail hard, fail fast mechanism
  - If your program has any logic bug, then you should fail as fast as possible to avoid data corruption, resource draining etc.

### Using `panic`
- We use panic because
1. If a server crashes it gets immediate attention; proactive log searches for problems are rare
2. We want evidence of the failure as close in time and space to the original defect in the code
   - E.g. tracebacks, connecting the crash to logs to explain the context etc.
3. In a distributed system, crash failures are the easiest to handle
   - Better to fully die than be a zombie or corrupt databases etc.
   - Not crashing may lead to Byzantine failures
- We should use panic when the assumptions of our own programming design or logic are **wrong**
- `panic` is similar to `assert` in other programming languages

### Comparing to Exceptions
- Exceptions were popularized to allow *graceful degradation* of safety critical systems. They were originally devised for the Ada programming language 
- The issue with exceptions is they introduce invisible control paths through code; code with exceptions is harder to analyze, both by eye and automatically

### `panic` and `recover`
- Go sort of supports exception like behaviour with `panic` and `recover`
- You can catch a `panic` only in a defer block using `recover()`:

```go
func abc() {
  panic("omg")
}

func main() {
  defer func() {
    if p := recover(); p != nil {
      // can't really do much else here other than print

      fmt.Println("recover: ", p)
    }
  }()

  abc()
}
```

- If we get a `panic`, there isn't much we can do other than print, since our program is in a corrupt state and we can't trust our assumptions any more

### Reducing Error Cases
- Errors (edge cases) are one of the primary sources of complexity in systems
- **The best way to deal with errors is to make them impossible**
- We should design abstractions so most (or all) operations are safe. For example all the below operations are safe in Go, when they might not be in other languages
  - Reading from a nil map
  - Appending to a nil slice
  - Deleting non-existent item from map
  - Taking the length of an uninitialised string
- Every piece of data in your software should start life in a valid state, and every transformation should leave it in a valid state
- Some golden rules:
  - Break large programs into smaller understandable pieces
  - Hide information to reduce chance of corruption
  - Avoid clever code and side effects
  - Avoid unsafe operations
  - Assert invariants
  - Never ignore errors
  - **Test**
  - And never ever except any input from a user or environment without validation

### Why?
- Go programmers are forced to think about the failure case first - this leads to programs where failures are handled at the point of writing rather than the point that they occur in production
- The verbosity of `if err != nil` is outweighed by the value of deliberately handling each failure condition at the point at which it occurs
- Most importantly we have visibility; the logic in the program is there for you to see. It may be more verbose but it is visible