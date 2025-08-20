# Matt Holiday Go Class (YouTube)
Notes from learning the fundamentals of the Go programming language from [this amazing tutorial](https://www.youtube.com/playlist?list=PLoILbKo9rG3skRCj37Kn5Zj803hhiuRK6). It is a fantastic video tutorial on YouTube that explains Go concepts from the ground up and offers some great insight into the language design 

- [Matt Holiday Go Class (YouTube)](#matt-holiday-go-class-youtube)
  - [Variables](#variables)
  - [Strings](#strings)
  - [Arrays and Slices](#arrays-and-slices)
  - [Maps](#maps)
  - [Various Builtin Functions](#various-builtin-functions)
  - [`nil` (From https://www.youtube.com/watch?v=ynoY2xz-F8s)](#nil-from-httpswwwyoutubecomwatchvynoy2xz-f8s)
    - [Nil Interfaces](#nil-interfaces)
  - [Control Statements](#control-statements)
  - [Packages](#packages)
  - [Imports](#imports)
  - [Variable Declarations](#variable-declarations)
    - [Short Declaration Operator `:=`](#short-declaration-operator-)
  - [Typing](#typing)
    - [Structural and Named Typing](#structural-and-named-typing)
  - [Functions](#functions)
    - [Parameter Passing](#parameter-passing)
    - [Multiple Return Values](#multiple-return-values)
    - [Naked Return Values](#naked-return-values)
    - [Defer](#defer)
  - [Closures](#closures)
  - [More on Slices](#more-on-slices)
    - [The Slice Operator](#the-slice-operator)
      - [The Slice Capacity Issue](#the-slice-capacity-issue)
    - [Array and Slice APIs From Here](#array-and-slice-apis-from-here)
  - [Structs and JSON](#structs-and-json)
    - [Maps of Structs](#maps-of-structs)
    - [Structure \& Name Compatibility of Structs](#structure--name-compatibility-of-structs)
    - [JSON with Structs](#json-with-structs)
  - [Reference and Value Semantics](#reference-and-value-semantics)
    - [More on Copying](#more-on-copying)
    - [Stack Usage and Escaping](#stack-usage-and-escaping)
  - [HTTP and Networking in Go](#http-and-networking-in-go)
  - [References](#references)

## Variables
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

## Strings
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

## Arrays and Slices
- Arrays have fixed size, slices are variable size
- Slices have a backing array to store the data; slice _descriptors_ (not an official thing - just used to denote the underlying logic of this data) have a length (how many things in the slice), a capacity (the capacity of the underlying array) and a pointer to the underlying array
- Slices are passed by reference, but you can modify them unlike strings
  - Arrays are passed by value 
- Arrays are also comparable with `==`, slices are obviously not. Arrays can be used as map keys, slices cannot
- Slices have `copy` and `append` helper operators
- Arrays are used almost as pseudo constants

## Maps
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

- **Important:** you cannot take the address of a map entry (e.g. like `&myMap["Hello"]`)
  - The reason for this is the map can change its internal structure and the pointers to entries are dynamic so it is very unsafe to reference a map entry 

## Various Builtin Functions
<figure>
<img loading="lazy" width="500" src="../Images/go-tutorial/builtins.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=T0Xymg0_aSU">https://www.youtube.com/watch?v=T0Xymg0_aSU</a>
</figcaption>
</figure>

## `nil` (From [https://www.youtube.com/watch?v=ynoY2xz-F8s](https://www.youtube.com/watch?v=ynoY2xz-F8s))
- `nil` indicates the absence of something, with part of the Go philosophy being to make the zero value useful
- The length of a nil slice is 0, you can read a map that doesn't exist - any key returns the default value. These features reduce code noise / boilerplate
- The `nil` value has no type; it is defined for the following constructs:
  - Nil pointer -> the zero value for pointers - points to nothing
  - Nil slice -> a slice with no backing array (with zero length and zero capacity)
  - Nil channels, maps and functions -> these are all pointers under the hood so a nil [channel,pointer,function] is just a nil pointer

### Nil Interfaces
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

## Control Statements
- If statements require braces
- We can have a short declaration in an if statement to simplify logic:

```go
if x, err := doSomething(); err != nil {
  return err  
}
```

- Only for loops exist in Go, no do or while
- We can do ranged for loops for arrays and slices:

```go
for i := range someArr {
  // i is an index here. Remember this - this mistake can happen often. i is the INDEX NOT THE VALUE. 
  // If you want to range over the values you can use the blank identifier like for _, v := range someArray
}

for i, v := range someArr {
  // i is an index, v is the value at that index
  // The value v is COPIED - don't modify. If the values are some large struct, it might be better to use the explicit indexing for loop
}

for k := range someMap {
  // Looping over all keys in a map
}

for k, v := range someMap {
  // Getting the keys and values in the loop
}
```

- Remember maps in Go have no order since they are based on a hashtable
  - To run through a maps values in key order, the keys must be extracted, sorted, then looped over to index into the map
- An infinite loop can be started with an empty for:

```go
for {
  // Infinite loop
}
```

- Switch statements are syntactic sugar for a series of if-then statements

```go
switch someVal {
  case 0,1,2:
    fmt.Println("Low")
  case 3,4,5:
    // Noop
  default:
    fmt.Println("Other")
}
```

- Cases break automatically in Go - no break statement is needed 
- There is also a switch on true statement which is used to make arbitrary comparisons:

```go
a := 3

switch {
  case a <= 2:
  case a == 8:
  default:
    // Do something
}
```

- It's basically just a bunch of if statements, evaluated in the order they are written

## Packages
- Every standalone program in Go must have a `main` package
- There are two main scopes in Go; package scope and function scope
- You can declare anything at package scope but you can't use the short declaration operator `:=`
  - This is to make the program easier to parse since every statement at the top level has a keyword (e.g. const, var, type, func etc.)
- Packages break the program down into independent parts
- Anything with a capital letter is exported 
- Within a package, everything is visible (even across multiple files - you can have multiple files under the same package)
- There is a standard library in Go with lots of useful features. There is also an "extension" to the standard library (e.g. for a package like "golang.org/x/net/html") that offers less stable packages that might be candidates for the standard library in the future.

## Imports
- Go imports are based on necessity, if an import isn't used within a file then it is a syntax error
- Go understandably doesn't allow circular imports
- There is an `init()` function for a package, however using this isn't really recommended
- *Packages should embed complex behaviour behind a simple API*

## Variable Declarations
- Using the `var` keyword

```go
var a int
var a int = 1
var c = 1       // Type inference
var d = 1.0

// Declaration block for simplicity
var (
  x, y int
  z    float64
  s    string
)
```

### Short Declaration Operator `:=`
- The short declaration operator `:=` is used to declare and assign to a variable
- It can't be used outside of functions (to allow for faster parsing of a program)
- It must declare at least one new variable:

```go
err := doSomething()
err := doSomethingElse() // This is wrong, you can't re-declare err
x, err := doSomethingOther() // This is fine since you are declaring the new var x, and just reassigning err from the original assignment on the skip line above
```

- The caveat to that final point is that we _can redeclare (shadow) to variables in an outer scope_
  - When using a short declaration in a control structure (e.g. `if _,err := do(); err != nil`), that err declaration is local to the control structure scope (that if block scope). 
- See example for a gotcha:

```go
func do() error {
  var err error

  for {
    n, err := f.Read(buf)

    if err != nil {
      break
    }

    doSomething(buf)
  }

  return err
}
```

- The mistake here is that the err in the for loop is of an inner scope, it shadows the one defined in the function scope above, and is lost when the for loop exits. Thus returning the err in the last line will _always be nil_ 

## Typing
### Structural and Named Typing
- Structural typing is based on the structure of a variable. Some examples of things with the same type:
  - Arrays with the same base type _and_ size
  - Slices with the same base type
  - Maps with the same key _and_ value types
  - Structs with the same sequence of field names and types
  - Functions with the same typed parameters and return types
- Named typing happens when you introduce a new custom type with the `type` keyword
  - Things are only the same type when they have the same declared named type, so declaring `type x int` means that you can't assign something with type `x` to `int` or vice versa, you would have to use a type conversion like `var thing x = x(12)`
- Integer literals are untyped - they can assign to any size integer without conversion, and can be assigned to floats, complex etc.
- The only overloaded operator in Go is the + operator to concatenate strings

## Functions
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

## Closures
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

## More on Slices
```go
// The following shows some different slices, with information on them given below

var s []int
t := []int{}
u := make([]int, 5)
v := make([]int, 0, 5)
w := []int{1,2,3,4,5}
```

- Before explaining each slice we define the slice descriptor (an internal thing) as a tuple of (length, capacity, arrAddr) 
  - Length is the amount of elements stored in the slice
  - Capacity is the size of the underlying array storing the values
  - `arrAddr` is a pointer to the underlying array
- `s` is an uninitialised or nil slice
  - It has 0 length, 0 cap and a nil pointer in `arrAddr`
- `t` is an initialised but empty slice
  - It has 0 length and 0 capacity and `arrAddr` points to a special sentinel _`struct{}`_ value (again an internal thing that is basically a nothing value but not nil)
  - This is because it has 0 capacity so it can't point to a concrete array of 0 length - this sentinel value is an internal language thing that isn't exposed
- `u` is an initialised slice with 5 length and 5 capacity
  - It will be storing 5 of the zero value of it's slice type - e.g. for int it would be [0,0,0,0,0]
  - **This is an important thing to remember - appending to this list will create a list of 6 elements not 1!!**
- `v` is an initialised slice with 0 length and 5 capacity
  - The underlying array will have a size of 5 but won't be storing anything - attempting to read from this will cause a panic since the length is 0

### The Slice Operator
- The slice operator allows you to take a view of a slice
- It looks like `a[0:2]` - which will take the 0 and 1 elements of `a` (it is exclusive for the _to_ side)

#### The Slice Capacity Issue
- The slice operator basically just creates a _view_ into the underlying array of a slice
- This means that when slicing a slice of e.g. size 5 to get `0:2`, you get back a slice descriptor with length 2 but capacity 5 (since the underlying array is the same and has length 5)
- You can then legally slice this slice at e.g. `0:3` and you'll get back a slice descriptor of length 3 - which will contain the value at index 2 of the original slice!!!
- **This is an important thing to remember**
- This design is maybe not ideal but it is what it is. To fix this the slice with capacity operator was introduced
- This looks like `a[0:2:2]` - this will create a slice descriptor of length 2 AND CAPACITY 2
  - This means if you append to this slice Go will have to allocate a new array with new size and importantly a new memory address so the append works properly and doesn't touch the underlying array of the original slice
- Slices are basically aliases to underlying arrays

### Array and Slice APIs [From Here](https://go.dev/blog/slices-intro)
- To create an array from an array literal you can do `b := [2]string{"Hello", "world"}`, and you can do `b := [...]string` to let Go determine the size of the array for you based on the proceeding literal
- Slices are made with the `make` function (`func make([]T, len, cap) []T`)
- `len` and `cap` functions can be used to retrieve the length and capacity of a slice
- You can take an array `arr` and create a slice referencing (or providing a view of) the storage of `arr` using `s := arr[:]`
- If you slice an array (or slice) with capacity 5, not from the 0th element, then the resulting slice will have a capacity equal to the original capacity minus the length of the specified slice range. This is a variation on the slice capacity issue above
  - You can grow the slice to the end of the backing array's length using `s = s[:cap(s)]`
- Growing a slice can be done by making a larger slice and copying the data into it

```go
s := make([]int, 5)

// This is basically the internal implementation of slice growing that Go uses when appending to a slice that has reached it's max capacity
t := make([]int, len(s), (cap(s)+1)*2)
copy(t, s)
s = t
```

- As mentioned a slice will be automatically grown when it's length reaches its capacity
  - `append(s []T, x ...T) []T`
- You can append a slice into another slice by using the `...` operator to expand the second arg into a list of args
  - `append(s, x...)` for `s []T` and `x []T`
- The zero value of a slice (nil) acts like a zero length slice so you can declare a slice variable (without initialising it) and then append to it in a loop:

```go

func filter(s []int, fn func(int) bool) {
  var res []int // == nil
  for _, v := range s {
    if fn(v) {
      res = append(res, v)
    } 
  }

  return res
}
```

- One gotcha with slices is re-slicing doesn't make a copy of the underlying array, so you could accidentally keep the underlying array around when only a small piece of the data is actually needed
  - To remedy this, make a new slice and copy only the useful data into it and the garbage collector will sort out the rest
 
## Structs and JSON
- Structs are an aggregate of multiple types of named fields

```go
type Employee struct {
  Name string
  Number int
  Boss *Employyee
  Hired time.Time
}
```

- You can use the printf (`%+v`) to pretty print a struct and it's fields

### Maps of Structs
- You can store maps of structs (e.g. `map[string]MyStruct`) however it is really bad practice to do this because a map's internal structure is dynamic
  - Instead it is recommended to store a map of pointers to structs (e.g. `map[string]*MyStruct`)
- You also can't perform mutation operations (e.g. `++`) on fields of structs by direct access (e.g. `myMap["thing"].IntField++`)
  - This is because the semantics of maps are that they are meant to store _values_ not references, so when you access a value in a map by it's key, you get a _copy_ of the value meaning you can't directly mutate it and have the map update

### Structure & Name Compatibility of Structs
- Anonymous structs with the same field names and types (**and tags**) are treated as being the same type by the compiler
- However when you give a struct a name with `type blah struct{...}`, that no longer is the case - structs with different names will always be different types even if they have the same field names and types
- You can convert structs if they have the same structure:

```go
type thing1 struct {
	field int
}
type thing2 struct {
	field int
}
func main() {
	a := thing1{field: 1}
	b := thing2{field: 1}
	a = thing1(b) // Valid
}
```

- The zero value of a struct is the zero value of all of it's fields
  - This is a core Go concept - make the zero value useful
- Structs are copied, so when they are passed in as parameters to functions a copy is made and modifications will only be made on the copy
- The dot notation for fields also works on pointers, e.g. for `thing *myStruct`, `thing.field` is equivalent to dereferencing `(*thing).field`
  - This is different to C/C++ where you'd use -> for accessing or mutating a field in a struct pointer
- Structs with no fields are useful - they take up no space
  - Some uses include creating a set (`map[int]struct{}`) or creating a `chan struct{}` to be a "complete" notifier without the need to pass any data if that isn't needed
  - The empty struct is a singleton - it is the sentinel value used to indicate an empty slice

### JSON with Structs
- Struct tags are key value pairs that can be attached to a struct field
- They can specify how struct fields should be serialised / deserialised by libraries (done with reflection)

```go
type Response struct {
  Data string `json:"data"` // Only exported fields are included in a marshalled JSON string
  Status int `json:"status"`
}

func main() {
  // Serializing
  r := Response{"Some data", 200}
  j, _ := json.Marshal(r)

  // j will be []byte containing "{"data":"Some data","status":200}"

  // Deserializing
  var r2 Response
  _ = json.Unmarshal(j, &r2)
}
```

## Reference and Value Semantics
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

## HTTP and Networking in Go
- 




## References
- [Go docs](https://go.dev/doc)
- [Effective Go](https://go.dev/doc/effective_go)
- [Matt Holiday Go Tutorial](https://www.youtube.com/playlist?list=PLoILbKo9rG3skRCj37Kn5Zj803hhiuRK6)
