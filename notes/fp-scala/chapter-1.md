## Chapter 1
- FP is all about using pure functions to write programs
### Intro to Scala
- Mostly familiar syntax, traits are more powerful interfaces
- Case classes are basically equivalent to data classes in Kotlin, they define a data type with immutable fields and auto generate helper methods
- In the cafe example the powerful thing is to return a charge (or list of charges) instead of performing side effects; this makes it a lot easier to reason about and test functions, as well as making combining easier
- In `List.fill(n)(buyCoffee(cc))` an interesting thing is done; the signature of `List.fill` is `override def fill[A](n: Int)(elem: => A): CC[A]`, this has two important syntactic things in it:
  - Firstly, it has "by-name" parameter elem; this is a lazily evaluated parameter, therefore it will be
  - Secondly, it has multiple parameter lists which basically means it's a curried function. This is not implicit as it is in Haskell

```scala
override def fill[A](n: Int)(elem: => A): CC[A] = {
    val b = newBuilder[A]
    b.sizeHint(n)
    var i = 0
    while (i < n) {
      b += elem // lazily evaluated, so will call buyCoffee() n times
      i += 1
    }
    b.result()
  }
```

- Referential transparency is. the idea that replacing an expression with it's result does not change the meaning or functioning of the program
- It enables equational reasoning about programs; computation proceeds by substituting equals for equals
- Something with internal state is not referentially transparent, for example StringBuilder

```scala
val x = new StringBuilder("Hi")
val y = x.append("Hi")
val r1 = y.toString() // -> HiHi
val r2 = y.toString() // -> HiHi
```

- If we were to replace the instances of `y` with the value of the RHS of the expression (`x.append("Hi")`), `r2` would evaluate to "HiHiHi", thus this is not referentially transparent; `StringBuilder.append` is not a pure function
- The idea of FP is to move side effects out to the edge of our program; this increases testability and readability of code