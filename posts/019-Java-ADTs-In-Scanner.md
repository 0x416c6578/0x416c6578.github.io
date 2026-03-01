# Learning Data Oriented Java - Messing with ADTs in a Scanner
I'm currently working through Robert Nystrom's _crafting interpreters_, specifically the Java implementation of the Lox interpreter. It's been a really interesting project so far (and apparently I actually remember more of my Programming Languages classes at university than I give myself credit for!), however I've been thinking about a more modern / _data oriented_ way of doing things, specifically to do with tokens in the scanner. This blog post tracks my thoughts when trying to use Java's "new" data oriented language features to more cleanly map to the Haskell language implementations I remember from university.

## Defining the Data Type
For the purposes of this blog post I present a super simple language that we will scan, consisting of purely +,- and integer literals. In Haskell we could trivially define this with an ADT:

```haskell
data Token = TokenOp Operator | TokenNum Int
data Operator = Plus | Minus
```

Now I present my train of thought when trying to do the same thing in Java:

### Sealed Interface with Records
```java
public sealed interface Token permits Token.Plus, Token.Minus, Token.NumberLit {
  record Plus() implements Token {}
  record Minus() implements Token {}
  record NumberLit(int number) implements Token {}
}
```

This was roughly my first iteration, using a sealed class with records representing each case in the sum type. However this didn't sit right with me, there was a lot of repetition and I felt like I was missing the utility of enums.

### Introducing Enums
```java
public sealed interface Token permits Token.Operator, Token.NumberLit {
  enum Operator implements Token {
    PLUS, MINUS
  }
  record NumberLit(int number) implements Token {}
}
```

Here since so many tokens in the language aren't literals (e.g. they don't have any variability to them), they don't need to be records; an enum should suffice. 

But then I decided I wanted to add _locality_ (the location in the source code, for error messaging) to a token - for that I'd need to re-balloon my enum into separate records, and have all records have a common `loc` to them?

### Wrapping with Locality
That didn't seem right, I looked back at the book and the `Token` in the book was a wrapper around a `TokenType` and a location, so this is eventually what I settled with. I now have a `TokenType` sealed interface for the `data Token = ...`, and then a `Token` record which collects a `TokenType` and location together. The best of every world!

Using Java sealed types I could get rid of the slightly smelly `Object lit` in `Token` and have a cleaner and more type safe implementation (:

```java
record Token(TokenType type, Location loc) {
    public record Location(int line, int offset) {}
    public sealed interface TokenType permits TokenType.Operator, TokenType.NumberLit {
        enum Operator implements TokenType {
            PLUS, MINUS
        }
        record NumberLit(int number) implements TokenType {}
    }
}
```

- Still not quite as clean as Haskell though ):
