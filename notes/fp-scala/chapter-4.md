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

#### Aside - By-name Parameters
- The parameters in `getOrElse` and `orElse` in the `Option` data type above are denoted like `=> B`, this means this is a by-name parameter
- The Scala compiler will wrap the parameter in a function that is only called when it is needed in the function implementation
  - Therefore, unlike normal parameters which are eagerly, by-name parameters are evaluated lazily
- It can be thought of as similar to the supplier function in Java Map's `computeIfAbsent` method, and under the hood works roughly the same way!

#### Aside - More on Variance
- The option type is **covariant** in `A`, this means that for some `B` which is a subtype of `A`, an `Option[B]` is a subtype of `Option[A]`
  - This is because the `Option` can be seen as a _producer_ of values of type `A`
  - If we had something that accepts `Option[Animal]`, we can safely pass in an `Option[Dog]` because `Dog` is _at least_ an `Animal` (if of course `Dog < Animal`!)
  - There's no way to accidentally put a non-`Dog` `Animal` into an `Option[Dog]` through type-safe means, so the substitution is sound
- In Java variance is done through generic wildcards, with the rule PECS - Producer Extends, Consumer Super
  - The _PE_ is equivalent to the covariance of `A` in `Option`, since it can be seen as a producer of values of type `A`
- The flip side is **contravariance** for consumer, a function that accepts a type can also accept any supertype of it
  - Because it can guarantee that any behaviour it might need of the type exists in the super types as well (at least at the type level)
  - E.g. `trait SomeFunc[-A, +B]: def apply(a: A): B`
- And finally there is **invariance** where you can't assume any behaviour
  - This could be some *mutable* box type with a `var` variable in it
  - In general immutable data types can be covariant, whereas mutable ones must be invariant
  - `List` in Scala is covariant on its type since it is immutable (similar to `Option`)

### Implementing the Option Methods

```scala
enum MyOption[+A]:
  case Some(get: A)
  case None

  def map[B](f: A => B): MyOption[B] = this match {
    case Some(a) => Some(f(a))
    case None => None
  }

  def getOrElse[B >: A](default: => B): B = this match {
    case Some(a) => a
    case None => default
  }

  def flatMap[B](f: A => MyOption[B]): MyOption[B] = map(f).getOrElse(None)

  // first map will make Some(Some(a)) | None; then getOrElse will extract some(a) or ob if None
  def orElse[B >: A](ob: => MyOption[B]): MyOption[B] = map(Some(_)).getOrElse(ob)

  // this could also just be done with a match
  def filter(f: A => Boolean): MyOption[A] = flatMap(a => if f(a) then Some(a) else None)
```

- We can think of the map function as transforming the result inside an option if it exists; proceeding a computation on the assumption that the error hasn't occurred
  - It can defer error handling code to later
- `flatMap` is similar except the function used to transform can itself fail
- E.g:

```scala
case class Employee(
  name: String,
  department: String,
  manager: Option[Employee])
def lookupByName(name: String): Option[Employee] = ...

lookupByName("Joe").map(_.department) // will return joe's department if joe is listed as an employee (from lookupByName), else None. Map is used since an employee will always have a department

lookupByName("Joe").flatMap(_.manager) // will return joe's managed if Joe has a manager, else None if Joe is not an employee or doesn't have a manager. FlatMap is used since an employee doesn't always have a manager
```

#### Exercise
```scala
def mean(xs: Seq[Double]): MyOption[Double] =
  if xs.isEmpty then None
  else Some(xs.sum / xs.length)

// we use flatmap to short circuit the computation if the mean is None
def variance(xs: Seq[Double]): MyOption[Double] =
  val m = mean(xs)
  m.flatMap(m => mean(xs.map(x => math.pow(x-m, 2))))
```

- A common pattern is to transform an `Option` using calls to `Map`, `FlatMap` and/or `Filter`, then using `getOrElse` to do error handling at the end
- Another common idiom is to do `o.getOrElse(throw Exception("Uh oh"))`, to convert the `None` case back to an `Exception`
  - This should **ONLY** be done in the cases where no reasonable program would catch the exception, e.g. if for some callers the exception is actually a recoverable error you should always use values like `Option` or `Either` rather than throwing an exception

### Option Composition and Lifting
- Using `Option` might imply it has to be used consistently across an entire codebase (similar to function colouring), but this isn't the case since we can `lift` ordinary functions to become functions that operate on `Option`:

```scala
def lift[A, B](f: A => B): Option[A] => Option[B] =
  a => a.map(f)

lift(math.abs) // returns lifted abs function
```

```scala
// this could be done with pattern matching but we can map/flatmap for nicer implementation
def map2[A, B, C](a: MyOption[A], b: MyOption[B])(f: (A, B) => C): MyOption[C] =
  a.flatMap(_a => b.map(_b => f(_a, _b)))
```

- Notice the pattern above of calling map then flatmap; we could do map then map and end up with an `Option[Option[C]]` then use `getOrElse`, but this is basically the definition of `flatMap` anyway (`map(g).getOrElse(None)`)

#### Aside on Parameter Lists
- This function has two parameter lists; `(a: MyOption[A], b: MyOption[B])` and `(f: (A, B) => C)`
- To call the function, we supply values for each parameter list like `map2(oa, ob)(_ + _)`
- It is common practice to use two parameter lists when a function takes multiple parameters and the last parameter is a function

```scala
map2(oa, ob): (a, b) =>
  a + b

// or 

map2(oa, ob) { (a, b) =>
  a + b
  }

// are both valid usages and can only be done with multiple parameter lists
```

#### Exercise 4.4
```scala
def sequence[A](as: MyList[MyOption[A]]): MyOption[MyList[A]] =
  foldRight(as, Some(Nil), (a, acc) => map2(a, acc)(Cons(_,_)))
```

- This is the implementation of `sequence` using `foldRight` and `map2`

#### Exercise 4.5
```scala
// naive implementation - uses sequence then map which loops over the list twice
def traverse[A, B](as: MyList[A])(f: A => MyOption[B]): MyOption[MyList[B]] =
  sequence(map(as, f))

// but we can do better, using a similar strategy as with sequence itself
def _traverse[A, B](as: MyList[A])(f: A => MyOption[B]): MyOption[MyList[B]] =
  foldRight(as, Some(Nil), (a: A, acc) => map2(f(a), acc)(Cons(_,_)))
```

### For Comprehensions
- The pattern of lifting functions with `map` and `flatMap` is so common that there is syntactic sugar with the `for` comprehension
  - This is basically identical to Haskell's `do` notation, although with slightly different syntax

```scala
def map2[A, B, C](a: Option[A], b: Option[B])(f: (A, B) => C): Option[C] =
  a.flatMap: aa =>
    b.map: bb =>
      f(aa, bb)

// can be converted to:
def map2[A, B, C](a: Option[A], b: Option[B])(f: (A, B) => C): Option[C] =
  for
    aa <- a
    bb <- b
  yield f(aa, bb)
```

- The bindings `<-` are desugared to `flatMap`, except  the final binding and `yield` is converted to a call to `map`
- The for comprehension stops the nesting from moving right which is nicer syntactically

### Either
- The `Either` data type is used to store more information on a failure rather than just `None` that `Option` holds

```scala
enum Either[+E, +A]:
  case Left(value: E)
  case Right(value: A)
```

- The `Either` data type has two data constructors, `Left` and `Right`
- The `Left` state represents failure; some error, and the `Right` represents the result of a successful computation
  - It is a disjoint union; a sum type

```scala
def safeDiv(x: Int, y: Int): Either[Throwable, Int] =
  try Right(x / y)
  catch case NonFatal(t) => Left(t)

// we can extract this logic into a function itself:
def catchNonFatal(a: => A): Either[Throwable, A] =
  try Right(a) // uses lazy evaluation; a will not be evaluated as an argument and so the exception will be thrown in this function 
  catch case NonFatal(t) => Left(t)
```

- Above is a safe division implementation that catches any non fatal exception and returns it in the error state, should one occur
