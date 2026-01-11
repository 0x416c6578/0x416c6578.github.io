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
```

