## Parametric Polymorphism (Video 42)
- Types of polymorphism
  - Inheritance (where one type derives from another)
  - Ad-hoc (overriding / overloading)
  - Type parametric (types are parameterised)
- As with generics in other languages, in Go you have to be restrained with usage since they can be a source of unnecessary abstraction and complexity
- Type parameters should be used to replace dynamic typing (e.g. using `any` (`interface{}`) and downcasting) with static typing (type parameters)

```go
// simple generic "map" function
func Map[F, T any](s []F, f func(F) T) []T {
    r := make([]T, len(s))
    for i, v := range s {
        r[i] = f(v)
    }

    return r
}
```

- Generics in Go use square brackets, which is a departure from things like Java which uses `<>`
  - This is to better fit with the existing parser behaviour

```go
type Vector[T any] []T

// generic Push function for this new generic vector type
// it takes in a pointer because append() might reallocate, so without 
// a pointer the reallocation would basically just be lost and nothing would result
func (v *Vector[T]) Push(x T) {
    *v = append(*v, x)
}

func main() {
  s := Vector[int]{}
  s.Push(1)
  s.Push(2)

  // using our Map function on the Vector type
  t1 := Map(s, strconv.Itoa)
}
```

- Since the type parameters in `Map` are both used in the formal parameters, we don't need to explicitly pass these type parameters in the call to `Map` shown above
  - If any of the type parameters isn't used in the formal parameters, then all type parameters must be specified in the call (e.g. `Map[int, string](...)`)
- Functional programming isn't really Go's forte, hence the slightly awkward ergonomics of writing the map function
  - This is kinda part of the language design

### Type Constraints
- We can provide type constraints on type parameters, that say that the type has to be one that conforms to the interface(s) specified

```go
type StringableVector[T fmt.Stringer] []T // our type T has to conform to the Stringer interface (implement String())

type num int
func (n num) String() {
  return strconv.Itoa(int(n)) // cast our type (this is fine since the underlying type of num is int)
}

func main() {
  var s StringableVector[num] = []num{1,2,3}

  fmt.Println(s)
}
```

- The goal of generics in Go are not to emulate features from other languages which can be generic heavy (e.g. STL, some Java code), and instead to just remove cases of dynamic typing (use of `interface{}`, casting etc.) for type safety at compile time
