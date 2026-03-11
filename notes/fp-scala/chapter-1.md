## Chapter 1
- FP is all about using pure functions to write programs
### Intro to Scala
- Mostly familiar syntax, traits are more powerful interfaces
- Case classes are basically equivalent to data classes in Kotlin, they define a data type with immutable fields and auto generate helper methods
- In the cafe example the powerful thing is to return a charge (or list of charges) instead of performing side effects; this makes it a lot easier to reason about and test functions, as well as making combining easier
- In `List.fill(n)(buyCoffee(cc))` an interesting thing is done; the signature of `List.fill` is `override def fill[A](n: Int)(elem: => A): CC[A]`, this has two important syntactic things in it:
  - Firstly, it has "by-name" parameter elem; this is a lazily evaluated parameter
  - Secondly, it has multiple parameter lists which basically means it's a curried function. This is not implicit as it is in Haskell
-
