## OOP Concepts in Go (Videos 17-20)
### An Overview
- Go offers OO programming concepts
  - Encapsulation using packages for visibility control
  - Abstraction and polymorphism using interface types
  - Composition (rather than inheritance) to provide structure sharing
- Go doesn't offer inheritance or substitutability based on types
  - Substitutability is based only on interfaces, a function of abstract behaviour
- Go offers more flexibility than OOP since it allows methods to be put on any user defined types rather than only "classes"
- Go also allows any *object* to implement the methods of an interface, not just a *subclass*

### Methods and Interfaces
*"An interface, which is something that can do something. Including the empty interface, which is something that can do nothing, which is everything, because everything can do nothing, or at least nothing."* - Brad Fitzpatrick

- Interfaces specify abstract behaviour - one or more methods that a concrete implementation must satisfy
- Interface satisfaction in Go is implicit - if a type implements the methods of an interface it automatically satisfies that interface, no _implements_ like keyword required
- A method is a special type of function that has a receiver parameter before the function name
  - This receiver parameter is actually just syntactic sugar for an additional argument for the thing the method is being called on, equivalent to _self_, _this_ etc. in other languages
- You can put methods on any user defined type, not just structs (although you can't put methods directly on inbuilt types)
  - E.g. you can define `type IntSlice []int` and attach a method to this named user-declared type, but you can't attach a method to `[]int` directly
- An example interface is the `Stringer` interface - this defines a method `String()` that can be used to stringify the receiving thing

```go 
type Stringer interface {
  String() string
}
```

- This interface is used by `fmt.Printf` - it will check if the thing it needs to print satisfies the Stringer interface (_is a_ stringer), and if so just copies the output of the `String()` method to its output
- Interfaces allow us to define functions in terms of abstract behaviour rather than concrete implementations, e.g. we can create an `OutputTo` function that accepts any type that implements the `Write([]byte)` method,  meaning we can use any thing that has that method rather than a specific implementation
- Methods can have value or pointer receivers, the latter allows you to modify the receiver (the original object)
  - You can't have a method with the same signature as both a pointer and a value receiver
- You can compose interfaces:

```go
type ReadWriter interface {
  Reader
  Writer
}
```

- Thus a `ReadWriter` must implement the `Read` and `Write` methods

### Interface Declarations
- All methods for a given type must be declared in the same package where the type is declared
  - This means the compiler knows all the methods for the type at compile time and ensures safe static typing
- However you can extend a type into a new package through embedding:

```go
type Bigger struct {
  otherpackage.Big // Struct composition to be explored later
}

func (b Bigger) SomeMethod() {

}
```

### Composition in Go
- You can embed a struct into another struct - the fields of the embedded struct are promoted to the level of the embedding struct

```go
type Host struct {
  Hostname string
  Port int
}

type SimpleURI struct {
  Host
  Scheme string
  Path string
}

func main() {
  s := SimpleURI{
		Host:   other.Host{Hostname: "google.com", Port: 8080},
		Scheme: "https",
		Path:   "/search",
	}

  fmt.Println(s.Hostname, s.Scheme) // See how the Host has been promoted
}
```

- The `SimpleURI` structure would have the fields in the `Host` struct promoted to it's level
- Importantly the methods on the `Host` type are also promoted to the `SimpleURI` type, this is the most powerful part of composition
- You can also embed pointers to other types - in this case the methods (both value and pointer receiver) on that embedded pointer are still promoted

```go
type Thing struct {
	Field string
}

func (t *Thing) bruh() {
	fmt.Println(t.Field)
}

// Would also be valid with a value receiver method
// func (t Thing) bruh() {
// 	fmt.Println(t.Field)
// }

type Thing2 struct {
	*Thing
	Field2 string
}

func main() {
	t := Thing2{&Thing{"Hello"}, "world"}
	t.bruh() // Method call here is valid
}
```

### Composition with Sorting Example
- The standard library sort package uses interfaces to sort things
- The main sort interface is:

```go
type Interface interface {
  // The length of the collection
  Len() int
  // Says whether the element at index i is less than the element at index j
  Less(i, j int) bool
  // Swaps the element at index i with the element at index j in the collection
  Swap(i, j int)
}
```

- Then the `sort.Sort` function can take in any `Interface` conforming collection type and sort it in place
- Example:

```go
type Component struct {
  Name string
  Weight int
}

type Components []Component

func (c Components) Len() int { return len(c) }
func (c Components) Swap() { c[i], c[j] = c[j], c[i] }
```

- Here we define a custom type `Component`, and we want to make `Components` sortable
- We could define a default sort strategy on `Components` with the `Less` function as follows:

```go
func (c Components) Less(i, j int) {
  // LT rather than the less than symbol because Jekyll
  return c[i].Weight LT c[j].Weight
}
```

- Thus `Components` can be sorted by weight by default
- However, we might want to define other sorting strategies, which we can use composition for:

```go
type ByName struct{ Components }
func (bn ByName) Less(i, j int) bool {
  return bn.Components[i].Name LT bn.Components[j].Name
}

type ByWeight struct{ Components }
func (bw ByWeight) Less(i,j int) bool {
  return bn.Components[i].Weight LT bn.Components[j].Weight
}
```

- `ByName` and `ByWeight` conform to `sort.Interface` through composition (since `Components` has the `Len` and `Swap` methods defined for it), but they then specialise the `Less` method to be a specific sorting strategy
- The `reverse` unexported struct in `sort` is used to sort something in reverse order

```go
type reverse struct {
  Interface // It just embeds sort.Interface
}

func (r reverse) Less(i, j int) bool {
  return r.Interface.Less(j, i) // Note swapped arguments for reverse sorting
}

func Reverse(data Interface) Interface {
  return &reverse{data}
}
```

- See how the `Less` method on `reverse` is flipped
  - Then how the function `sort.Reverse` is defined that returns a `sort.Interface` that has the reverse implementation of `Less`

### Making Nil Useful
- One of the key concepts in Go is the idea that we can make `nil` useful
- There is nothing stopping you from calling a method on a nil receiver

```go
// The nil / zero value of this struct is ready to use since a nil slice can be appended to
type StringStack struct {
  data []string
}

func (s *StringStack) Push(x string) {
  s.data = append(s.data, x)
}

func (s *StringStack) Pop() string {
  l := len(s.data)

  if l == 0 {
    panic("pop from empty stack")
  }

  t := s.data[l-1]
  s.data = s.data[:l-1]
  return t
}
```

- In the above example, the zero value of StringStack is directly usable
- This is also a good example of encapsulating the `data` field inside the `StringStack` struct so that a client can't see the implementation details
- Another example of making nil useful is a recursive linked list traversal:

```go
type IntList struct {
  Value int
  Tail *IntList
}

func (list *IntList) Sum() int {
  if list == nil {
    return 0
  }
  
  return list.Value + list.Tail.Sum()
}
```

- See how the base case is elegantly handled by the nil receiver 

### Exploring Value / Pointer Method Semantics
- Go performs some implicit addition of things when calling value / pointer receivers on values / pointers
- If you have a value `v := T{}` you can of course call value receivers on it directly, however you can also call pointer receivers on it. The compiler will implicitly add an `(&v).PointerMethod()`
- Likewise if you have a pointer `v := &T{}`, you can of course call pointer receiver methods on it directly, however Go will also implicitly add a dereference when you call a value receiver method `(*v).PointerMethod()`
- Although the compiler does this implicitly, the *method sets* (which are important for interfaces) of a pointer and value type are as follows:
  - The method set of a value `T` is all the value receiver methods of `T`
  - The method set of a pointer `*T` is all the value and pointer receiver methods of `T`

```go
type Thing struct{}

func (t Thing) ValMethod() {}
func (t *Thing) PointerMethod() {}

type IVal interface { ValMethod() }
type IPtr interface { PointerMethod() }

func main() {
  var t Thing

  var iVal IVal
  var iPtr IPtr

  iVal = t  // Valid
  iVal = &t // Valid

  iPtr = t  // Not valid, since the value t doesn't have the pointer method PointerMethod in it's method set
  iPtr = &t // Valid
}
```