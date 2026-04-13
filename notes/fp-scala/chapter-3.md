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
  - Having the `apply` function here means that we can do `List(1,2,3)`
  - Companion objects have access to private and protected members of the type with the same name, but otherwise function like any other object
- This is a polymorphic data type where the type parameter A is a _covariant_
  - Covariant means that that if `X` is a subtype of `Y` then `List[X]` is a subtype of `List[Y]`
  - `Nothing` is a subtype of all types, meaning `Nil` can be considered a `List[Int]`, `List[Double]` etc.

### Pattern Matching
- Scala has pattern matching similar to Haskell, but using `match` and `case` keywords

```scala
def sum(ints: List[Int]): Int = ints match
  case Nil => 0
  case Cons(x, xs) => x + sum(xs)

def product(doubles: List[Double]): Double = doubles match
  case Nil => 1.0
  case Cons(0.0, _) => 0.0
  case Cons(x, xs) => x * product(xs)
```

- Pattern matching is quite simple, and these are recursive functions since `List` is a recursive data structure
- A pattern may contain literals, like 3 or "hi"; variables, like x and xs, which match anything, indicated by an identifier starting with a lowercase letter or underscore; and data constructors, like Cons(x, xs) and Nil, which match only values of the corresponding form.
- If multiple patterns match the target, then the first case is chosen
- We can use `_` match pattern which matches any expression
- A `MatchError` is thrown when a match expression is not exhaustive; you should always have a fallback case in a match statement to avoid this
  - Scala will tend to warn if the pattern match isn't exhaustive