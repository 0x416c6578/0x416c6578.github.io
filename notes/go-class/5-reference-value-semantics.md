## Reference and Value Semantics (Video 14)
- Value semantics (copying) lead to higher integrity, especially in concurrent programs
- Pointer semantics tend to be more efficient
- Pointers are used when
  - Some objects can't be copied (e.g. a mutex)
  - When we don't what to copy a large data struct
  - Some methods needs to mutate the receiver
  - When decoding protocol data into a DTO
  - When we need the concept of "null", e.g. in a tree structure to indicate a node has no children

### More on Copying
- Any struct that has a mutex cannot be copied - it must be passed via a pointer
  - Likewise for WaitGroups
- Any small struct (under 64 bytes) can be copied since that is smaller than the size of a pointer
  - Larger structs should be passed by reference
  - String and slice descriptors are copied - however this is fine since the underlying data isn't copied - the copied descriptor points to the same underlying data as the original
- When you do a range in a for loop, the thing is **always a copy**:

```go
for i, thing := range things {
  // thing is always a copy - mutating it doesn't mutate the thing in things
}

// You have to use an index if you want to mutate the element
for i := range things {
  things[i].field = value
}
```

- If you have a function that mutates a slice that is passed in, you must return a copy - this is because the slice's backing array may be reallocated when it is grown:

```go
func update(things []thing) []thing {
  things = append(things, x) // Copy
  return things
}
```

### Stack Usage and Escaping
- Go will prefer storing things on the stack if it can
- It performs escape analysis to determine if something must be moved to the heap. Some cases that require moving to the heap are:
  - Function returns a pointer to a function local object
  - Local object is captured in a function closure
  - Pointer to a local object is sent via a channel
  - An object is assigned into an interface
  - Any object whose size is variable at runtime (e.g. slices)
- Run `go build -gcflags -m=2` to see the results of escape analysis