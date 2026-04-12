## Chapter 3
- Functional data structures are operated on using only pure functions; they are by definition immutable
- This chapter focuses on a `List` implementation

### Singly Linked Lists
```scala
enum List[+A]:
  case Nil
  case Cons(head: A, tail: List[A])

object List:
  def apply[A](as: A*): List[A] =
    if as.isEmpty then Nil
    else Cons(as.head, apply(as.tail*))
```

- Shown above is a simple definition of a singly linked list using data constructions in a sum type (enum)
  - In Java this would be done using sealed interfaces -> definitely not as ergonomic
- There is also a _companion_ object which allows us to construct lists using a variadic function syntax like `List(1,2,3)`
- This is a polymorphic _covariant_ data type
  - Covariant means that that if `X` is a subtype of `Y` then `List[X]` is a subtype of `List[Y]`
