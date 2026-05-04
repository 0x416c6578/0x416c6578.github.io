## Chapter 4
### Motivation
- A key idea in functional programming is returning errors as values rather than throwing exceptions
- Higher order functions abstract out the common patterns of error handling and recovery
- Throwing exceptions breaks referential transparency:

```scala
def f(i: Int): Int = 
  val y: Int = throw Exception("fail")
  try
    val x = 42 + 5
    x + y
  catch
    case e: Exception => 43
```

- The above is not referentially transparent because we can't replace y in x+y with the value above, since this exception will be thrown and caught, returning 43
- Non-RT expressions requires context and global reasoning, RT ones can be reasoned about entirely locally
- Java does have checked exceptions, which syntactically enforce callers to handle possible exceptions, however this isn't part of the type system and so higher order functions (e.g. map) cannot feasibly know all the number of checked exceptions it could throw (depending on the function `f` passed in)
  - Quite often generic code often resorts to using RuntimeException or some common checked Exception type even in Java
- We could return some bogus or sentinel value for undefined inputs of a function (e.g. calculating the mean of an empty list), however this is bad for two reasons
  1. Errors can silently propagate - there is nothing in the type system alerting the caller that the sentinel value is bad
  2. It adds extra boilerplate (`if retVal == sentinel` and so on)
  3. It doesn't work with polymorphic code, a function like `def max[A](xs: Seq[A])(greater: (A,A) => Boolean): A` which returns the largest value in `xs` based on the `greater` function semantics, if `xs` is empty we can't invent a sentinel of type `A`, nor return `null` since `null` is only valid for non-primitive types (and `A` could be primitive in this case, e.g. `Double`)
  4. It demands a special policy / calling convention of callers which makes it hard to use as a higher order function

### `Option`
- Option is the first approach outlined for functions that may not return a result

```scala
enum Option[+A]:
  case Some(get: A)
  case None
```

- The return type now reflects the possibility of the output being undefined
- `Option` and other data types allow for factoring out of common patterns of error handling via higher order functions
- Functions on the `Option` type:

```scala
enum Option[+A]:
  case Some(get: A)
  case None

  def map[B](f: A => B): Option[B] // apply f if option is not None
  def flatMap[B](f: A => Option[B]): Option[B] // apply f (which may fail) if option is not None
  def getOrElse[B >: A](default: => B): B // get option, or default value (which must be a supertype of A)
  def orElse[B >: A](ob: => Option[B]): Option[B] // get option, or 
```
