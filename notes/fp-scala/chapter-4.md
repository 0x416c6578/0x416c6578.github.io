## Chapter 4
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
