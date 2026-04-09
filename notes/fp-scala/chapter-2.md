## Chapter 2
### Scala Introduction - Various Notes
- It is easy to declare a singleton - just do `object SomeObject:` with a definition; defines the class and it's only instance
- Most of the basic syntax is easy enough to understand - function return types are optional if they can be inferred (although it is good style to include them anyway)
- Also functions don't have `return`, they just return the result of the final expression in the function body block
- Blocks in Scala are denoted by indentation, however curly braces can be optionally used if needed
- The term _procedure_ is given to an impure function
  - By convention, parentheses are included on procedures argument lists (e.g. `@main def main(): Unit`) even if they take no parameters
    - These parentheses are optional if the function / procedure doesn't take any arguments
- The unit type has one value, the literal syntax is `()`
  - Usually a return type of `Unit` means the function is a procedure (has some side effects)
- The Scala REPL is similar to the Haskell one, you can load a `.scala` file with `:load file.scala`
  - This only works for Scala files without a package declaration

### Objects and Namespaces
- Every value in Scala is an _object_ - an object can have 0 or more members which can be methods, or another object declared with `val` or `object`
  - There are also other members which aren't yet covered
- Objects can basically be thought of as instances of anonymous classes
- We use dot notation to access members of an object, e.g. `SomeObject.someFunc()`
- Operator overloading is quite simple in Scala; any symbolic single argument method can be used as an infix function
  - It also has backtick infix functions which are a bit terse
- We can `import SomeObject.*` to import all non private members of an object `SomeObject`

### Higher Order Functions
- Functions are (as expected) first class in Scala

### Tail Call Optimisation
```scala
def factorial(n: Int): Int =
  def go(n: Int, acc: Int): Int =
    if n <= 0 then acc
    else go(n-1, n*acc)
  go(n,1)
```

- Above is a tail recursive factorial implementation; since there is no additional work to do after the recursive call, this can be optimised into a simple loop
  - More formally, a call is said to be in tail position if the caller does nothing other than return the value of the recursive call
- We can use `@annotation.tailrec` to verify that a recursive function is eliminated to a loop

```scala
def fib(n: Int): Int =
  if n == 0 then return 0
  if n == 1 then return 1
  
  @tailrec
  def go(n: Int, prev: Int, curr: Int): Int =
    if n == 2 then prev + curr
    else go(n - 1, curr, prev + curr)

  go(n, 0, 1)
```

- The above code is a tail recursive implementation of the nth fibonacci number

### Higher Order Functions
- Functions in Scala are properly first class (unlike Java)

```scala
def formatResult(name: String, n: Int, f: Int => Int) =
  val msg = "The %s of %d is %d."
  msg.format(name, n, f(n))
```

- Here we see the syntax

### Polymorphic Functions
```scala
def findFirst[A](as: Array[A], p: A => Boolean): Int =
  @tailrec
  def loop(n: Int): Int =
    if n >= as.length then -1
    else if p(as(n)) then n
    else loop(n+1)
```

- The above function is polymorphic; generic over any type A with a predicate p used to determine which element to search for
- The type parameters introduce type variables that we can reference in the rest of the function signature

### Anonymous Functions (Lambdas, Function Literals)
- When using higher order functions, function literals are often used

```scala
findFirst(
  Array(7,9,13),
  (x: Int): Boolean => x == 9 // the : Boolean here is optional - Scala can infer this
)
```

- Also see the array literal syntax used here
- When the type of the function’s inputs can be inferred, the type annotations on the function’s arguments may be omitted
  - For example, `(x,y) => x < y`

```scala

```
