# Matt Holiday Go Class (YouTube)
Notes from learning the fundamentals of the Go programming language from [this amazing tutorial](https://www.youtube.com/playlist?list=PLoILbKo9rG3skRCj37Kn5Zj803hhiuRK6). It is a fantastic video tutorial on YouTube that explains Go concepts from the ground up and offers some great insight into the language design 

## Notes
- Variables are defined with the `var` keyword or the shorthand `:=` (only inside of functions / methods to simplify parsing!).

```go
var a int
// or
a := 2 // in functions or methods
```

- Fun Printf snippet - `%d %[1]v` will _reuse_ the first passed in argument (e.g. if we want to print a single variable twice in a Printf, you'd normally do `fmt.Printf("%d %d", a, a)`, but with this you just need to do `fmt.Printf("%d %[1]v", a)` and that parameter `a` will be reused)
- Only numbers, strings or booleans can be constants

```go
const(
    a = 1
    b = 3 * 100
    s = "hello"
)
```

### Strings
- `byte` is a synonym for `uint8`
- `rune` is a synonym for `int32` for characters 
- `string` is an _immutable_ sequence of "characters"
  - Logically a sequence of unicode `runes`
  - Physically a sequence of bytes (UTF-8 encoding)
- We can do raw strings with backticks (they don't evaluate escape characters such an `\n`)

```go
`string with "quotes"`
```

- IMPORTANT: The length of a `string` is the number of UTF-8 bytes required to encode it, NOT THE NUMBER OF LOGICAL CHARACTERS
- Internally strings consist of a length (remember that they are immutable) and a pointer to the memory where the string is stored. Since the _descriptor_ contains a length, no null byte termination is needed (as is the case in C)
- Strings are passed by reference
- The `strings` package contains useful string functions

### Arrays and Slices
- Arrays have fixed size, slices are variable size
- Slices have a backing array to store the data; slice _descriptors_ (not an official thing - just used to denote the underlying logic of this data) have a length (how many things in the slice), a capacity (the capacity of the underlying array) and a pointer to the underlying array
- Slices are passed by reference, but you can modify them unlike strings
  - Arrays are passed by value 
- Arrays are also comparable with `==`, slices are obviously not. Arrays can be used as map keys, slices cannot
- Slices have `copy` and `append` helper operators
- Arrays are used almost as pseudo constants

### Maps
- Maps are implemented using a hash table
- When you try to read a key that doesn't exist, you receive the default value of the map value type (e.g. for an `int` you'd get 0)
- You can also read from nil (uninitialised) maps, again will return the default value for any key

```go
var m map[string]int // nil map (reading any key will return the default value of the map value type)
_m := make(map[string]int) // empty non-nil map
```

- `make` creates the underlying hash table and allocates memory etc. It is required to instantiate and write to a map
- Maps are passed by reference, and the key type must have == and != defined (so the key cannot be a slice, map or function)
- Map literals are a thing:
```go
var m = map[string]int {
  "hello": 1
}
```
- Maps can be created with a set capacity for better performance
- Maps also have a two-result lookup function:

```go
p := map[string]int{} // Empty non nil map
a, ok := p["hello"] // Returns 0, false since the key "hello" doesn't exist
p["hello"]++
b, ok := p["hello"] // Returns 1, true

if w, ok := p["the"]; ok {
  // Useful if we want to do something if an entry is / isn't in the map
}
```

### Various Builtin Functions
<figure>
<img loading="lazy" width="500" src="../Images/go-tutorial/builtins.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=T0Xymg0_aSU">https://www.youtube.com/watch?v=T0Xymg0_aSU</a>
</figcaption>
</figure>

### `nil` (From [https://www.youtube.com/watch?v=ynoY2xz-F8s](https://www.youtube.com/watch?v=ynoY2xz-F8s))
- `nil` indicates the absence of something, with part of the Go philosophy being to make the zero value useful
- The length of a nil slice is 0, you can read a map that doesn't exist - any key returns the default value. These features reduce code noise / boilerplate
- The `nil` value has no type; it is defined for the following constructs:
  - Nil pointer -> the zero value for pointers - points to nothing
  - Nil slice -> a slice with no backing array (with zero length and zero capacity)
  - Nil channels, maps and functions -> these are all pointers under the hood so a nil [channel,pointer,function] is just a nil pointer
#### Nil Interfaces
- Nil interfaces -> I still don't fully understand this but interfaces internally have two things - the type of the value inside and the value itself

```go
var s fmt.Stringer   // This is a nil interface with no concrete type and no value (nil, nil)

fmt.Println(s == nil)   // Will print true since (nil, nil) == nil

//---

var p *Person // This Person satisfies the person interface

var s fmt.Stringer = p // Now we have (*Person, nil) - a concrete type (*Person) but still no value. This is now no longer equal to nil

//---

func do() error { // This will return the nil pointer wrapped in the error interface (*doError, nil)
  var err *doError
  return err // This is a nil pointer of type *doError
}

fmt.Println(do() == nil) // Will be FALSE because of the above example - (*doError, nil) != nil!!!

// It is good practice to not define or return concrete error variables
```