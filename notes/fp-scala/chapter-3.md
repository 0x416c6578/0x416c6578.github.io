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

### Data Sharing in Functional Data Structures
- Whist it might look immutable data structures are copied quite a lot, optimisations in most functional languages and the immutability guarantees means that they can be reused most of the time
- We know we can always return immutable data without it being modified in the future

#### Exercises:
```scala
def tail[A](xs: MyList[A]): MyList[A] = xs match
  case Nil => sys.error("Nil list; no tail")
  case Cons(x: A, xs: MyList[A]) => xs

def setHead[A](x: A, xs: MyList[A]): MyList[A] = Cons(x, tail(xs))

@tailrec
def drop[A](as: MyList[A], n: Int): MyList[A] = n match {
  case 0 => as
  case n => as match {
    case Nil => Nil
    case Cons(a, as) => drop(as, n - 1)
  }
}

// technique time!! wrapping multiple arguments in a tuple allows for much nicer pattern matching more similar to Haskell!!1

@tailrec
def drop[A](as: MyList[A], n: Int): MyList[A] = (as, n) match {
  case (_, 0) => as // scrumptious
  case (Nil, _) => Nil
  case (Cons(a, as), n) => drop(as, n - 1)
}

@tailrec
def dropWhile[A](as: MyList[A], f: A => Boolean): MyList[A] = as match {
  case Nil => Nil
  case Cons(a, as) => if f(a) then dropWhile(as, f) else Cons(a, as)
}

// note this is not tail recursive - it will create a stack frame for every element in the list so can StackOverflow
def init[A](as: MyList[A]): MyList[A] = as match {
  case Nil => sys.error("init of empty list")
  case Cons(a, Nil) => Nil
  case Cons(a, rest) => Cons(a, init(rest))
}
```

### More Recursion Over Lists
- `sum` and `product` have similar forms, only different cases for empty list (0 vs 1.0) and a different combination operator (`+` vs `*`)
- Therefore we can pull out the constant and the function here to produce a general function `foldRight`

```scala
// value returned doesn't need to be the same type of the list
def foldRight[A, B](as: List[A], acc: B, f: (A, B) => B): B =
  as match
    case Nil => acc
    case Cons(x, xs) => f(x, foldRight(xs, acc, f))
```

- And so `sum` would be `foldRight(ns, 0, _ + _)` and `product` would be `foldRight(ns, 1.0, _ * _)`
- We can see how `foldRight` is it replaces the `Nil` and `Cons` in `List` with `acc` and `f`
  - Where `Cons(1, Cons(2, Nil))` => `f(1, f(2, acc))`
  - We can look at this as an identity
- `foldRight` must traverse all the way to the end of the list before it can collapsing it; it's why it's called `foldRight` since it begins at the rightmost end of the list and works back to the start
  - Hence we can't short circuit something like `product`

### Exercises and Notes From These
```scala
// length of a list is pretty trivial
def length[A](as: MyList[A]) = foldRight(as, 0, (_, acc) => acc + 1)

// foldLeft can be tail recursive
@tailrec
def foldLeft[A, B](as: MyList[A], acc: B, f: (B, A) => B): B = as match {
  case Nil => acc
  case Cons(a, as) => foldLeft(as, f(acc, a), f)
}

def sum(xs: MyList[Int]) = foldLeft(xs, 0, _+_)
def product(xs: MyList[Int]) = foldLeft(xs, 1.0, _*_)

// we can define a reversal by foldLeft with Cons, since we work from the left hand side we can build up the
// list in reverse order
def reverse[A](xs: MyList[A]) = foldLeft(xs, Nil, (xs: MyList[A], x: A) => Cons(x, xs))

// we can write foldRight in terms of foldLeft by reversing the list first
def foldRight'[A, B](as: List[A], acc: B, f: (A, B) => B): B = foldLeft(reverse(as), acc, (b, a) => f(a, b))
```

### Intuition of FoldLeft and FoldRight
- Left and right folds are a fundamental idea in functional programming
- Left fold intuitively works from the left, since it immediately calls `f` on every recurse
- Right fold intuitively works from the right, since it has to unroll on the whole list before calling `f`

### Right Fold via Left Fold -> Uh Oh
- Although we can define foldRight in terms of foldLeft using reversal, this is a bit of a hack
- There is another way, slightly trickier but quite elegant
- The accumulator is now of type `B->B` rather than just `B`, and looking at foldLeft we know the combining function must be of type `(B->B, A) -> B->B`
- Now we can introduce a lambda on the RHS, leaving us with the signature `(g: B=>B, a: A) => (b: B) => ???` where `???` is of type `B`
- And we know we have an `a:A`, a `b:B`, a function `g: B=>B` and a function `f: (A,B)=>B`, and it falls out of this that we can just apply `g(f(a,b))` to get our type `B`

```scala
// so we now have this abomination:
def foldRight'[A, B](as: List[A], acc: B, f: (A, B) => B): B =
  foldLeft(as, (b: B) => b, (g, a) => b => g(f(a, b)))(acc)
```

- Everything before `(acc)` gives us a function of type `B=>B`, which we apply to `acc` to get our final `B`
- This is intuitively not stack safe since function composition is stack safe, our accumulator grows by one anonymous function each call, which is not stack safe
- The inverse can be applied to define right fold via left fold

### More Exercises
```scala
def append[A](a1: MyList[A], a2: MyList[A]): MyList[A] =
  foldRight(a1, a2, Cons(_, _))

// we can just use our append function to concatenate a list of lists together
def concat[A](as: MyList[MyList[A]]): MyList[A] =
  foldRight(as, Nil, append)
```

### Other Functions on Lists
```scala
def addOne(xs: MyList[Int]): MyList[Int] =
  foldRight(xs, Nil: MyList[Int], (i, acc) => Cons(i + 1, acc))

def convertToString(ds: MyList[Double]): MyList[String] =
  foldRight(xs, Nil: MyList[String], (d, acc) => Cons(d.toString, acc))

// we can generalise the logic in the two functions above into `map`
def map[A, B](as: MyList[A], f: A => B): MyList[B] =
  foldRight(as, Nil, (a, acc) => Cons(f(a), acc))

// we can define filter similarly to map except we drop the element if the predicate doesn't match
def filter[A](as: MyList[A], f: A => Boolean): MyList[A] =
  foldRight(as, Nil: MyList[A], (a, acc) => if f(a) then Cons(a, acc) else acc)

// we can then define flatMap by calling our expanding function `f` on each element and appending the resulting list to the accumulator
def flatMap[A, B](as: MyList[A], f: A => MyList[B]): MyList[B] =
  foldRight(as, Nil, (a, acc) => append(f(a), acc))

// using flatMap to implement filter
def filterPrime[A](as: MyList[A], f: A => Boolean): MyList[A] =
  flatMap(as, a => if f(a) then MyList(a) else Nil)

def addLists(xs: MyList[Int], ys: MyList[Int]): MyList[Int] = (xs, ys) match {
  case (xs, Nil) => Nil
  case (Nil, ys) => Nil
  case (Cons(x, xs), Cons(y, ys)) => Cons(x + y, addLists(xs, ys))
}

// we can generalise addLists to take an arbitrary function
def combine[A, B, C](as: MyList[A], bs: MyList[B], f: (a: A, b: B) => C): MyList[C] = (as, bs) match {
  case (as, Nil) => Nil
  case (Nil, bs) => Nil
  case (Cons(a, as), Cons(b, bs)) => Cons(f(a, b), combine(as, bs, f))
}
```

- The `combine` function above is normally called `zipWith`
- It currently isn't tail recursive but we can make it so:

```scala
// we build an accumulator up in a tail recursive fashion 
def zipWithTailRec[A, B, C](a: MyList[A], b: MyList[B], f: (A, B) => C): MyList[C] =
  @tailrec
  def loop(a: MyList[A], b: MyList[B], acc: MyList[C]): MyList[C] =
    (a, b) match
      case (Nil, _) => acc
      case (_, Nil) => acc
      case (Cons(h1, t1), Cons(h2, t2)) => loop(t1, t2, Cons(f(h1, h2), acc))
  reverse(loop(a, b, Nil))
```

- The reverse is needed because the accumulator fills up backwards

### Standard Library `List`
- There are many useful methods defined on `List`, for example scans `List(1,2,3).scanLeft(0)((acc, a) => a + acc)`

```scala
@tailrec
def hasSubsequence[A](sup: MyList[A], sub: MyList[A]): Boolean =
  // we define a helper function to determine whether a list starts with a given prefix
  @tailrec
  def startsWith(l: MyList[A], prefix: MyList[A]): Boolean = (l, prefix) match
    case (_, Nil) => true
    case (Cons(h, t), Cons(h2, t2)) if h == h2 => startsWith(t, t2)
    case _ => false

  // then we just wander down the sup list until we hit various conditions (startsWith is true, Nil, otherwise check for tail subsequence)
  sup match
    case Nil => sub == Nil
    case _ if startsWith(sup, sub) => true // guard condition
    case Cons(h, t) => hasSubsequence(t, sub)
```

### ADTs and Trees
- Algebraic data types are defined by one or more data constructors - each data type is the _sum_ (union) of it's data constructors, and each data constructor is the _product_ of it's arguments
  - The cardinality of a data constructor (e.g. `Square int int`) is `|int|*|int|`, and the cardinality of the data type `Shape = Square int int | Circle radius` is `|Shape|+|Circle|`
- Tuples in Scala are given some syntactic sugar
  - Construction via `(a,b)`
  - Selection using `t(1)`
  - Destruction / pattern matching via `t match (a,b) => a`

#### Binary Tree
- We can define a simple binary tree data structure using case classes:

```scala
enum Tree[+A]:
  case Leaf(value: A)
  case Branch(left: Tree[A], right: Tree[A])
```

- We can define the method size on `Tree` to count the number of nodes (branch and leaf nodes)

```scala
def size: Int = this match {
  case Leaf(_) => 1
  case Branch(l, r) => 1 + l.size + r.size
}
```

#### Extension Methods
- Say we want to define a method to find the first positive value in a `Tree[Int]`, we can't define this as a method on `Tree[A]`
- Instead we can define an extension method on `Tree[Int]`

```scala
extension (t: Tree[Int]) def firstPositive: Int = t match
  case Leaf(i) => i
  case Branch(l,r) =>
    val lpos = l.firstPositive
    if lpos > 0 then lpos else r.firstPositive
```

- This works like a method (where `t` is equivalent to `this`), however we can define it on the non parameterised type `Tree[Int]`, and it will only be available for trees of that type
- Extension methods should be defined int he companion object for `Tree`, there are other places it can be stored but this is the most common

### Tree Functions Exercises
```scala
def maximum(t: Tree[Int]): Int = t match {
  case Leaf(v) => v
  case Branch(l, r) => maximum(l).max(maximum(r))
}

def depth[A](t: Tree[A]): Int = t match {
  case Leaf(v) => 1
  case Branch(l, r) => 1 + depth(l).max(depth(r))
}

def map[A, B](f: A => B, t: Tree[A]): Tree[B] = t match {
  case Leaf(x) => Leaf(f(x))
  case Branch(l, r) => Branch(map(f, l), map(f, r))
}

// we can define a fold algorithm that generalises the logic in the above functions
def fold[A, B](t: Tree[A], f: A => B, g: (B, B) => B): B = t match {
  case Leaf(v) => f(v)
  case Branch(l, r) => g(fold(l, f, g), fold(r, f, g))
}

def foldSize[A](t: Tree[A]): Int = fold(t, _ => 1, 1 + _ + _)

def foldMaximum(t: Tree[Int]): Int = fold(t, a => a, _.max(_))

def foldDepth[A](t: Tree[A]): Int = fold(t, _ => 1, 1 + _.max(_))

def foldMap[A, B](t: Tree[A], f: A => B): Tree[B] = 
  fold(t, Leaf(f(_)), Branch(_, _))
```

- The above could all equally be defined as methods, should one desire

#### Aside - Enums vs Sealed Traits
- Enums of case classes are a Scala 3 thing, and make writing ADTs a bit less verbose
- Traits define abstract interfaces of common methods (they can't be instantiated directly, rather are introduced via subtypes)
- Defining an ADT as a sealed trait involves enumerating data constructors as case objects defined in the companion object of the trait
  - Remember a case class in Scala is just like a data class in Kotlin
  - `sealed` is the same as Java - all subclasses must be defined in teh same source file as the defining type

```scala
// we can define our List as a sealed trait rather than an enum:
sealed trait List[+A]:
  import List.{Cons, Nil}

  def size: Int = this match
    case Cons(_, t1) => 1 + t1.size
    case Nil => 0

object List:
  case class Cons[+A](head: A, tail: List[A]) extends List[A]
  case object Nil extends List[Nothing]
```

### Conclusion
