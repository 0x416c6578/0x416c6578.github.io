## Working with Types
- A type defines the following things:
  - Amount of memory required for the data needed to support the operations valid on that type
  - The rules of how to interpret the bits of memory as values of that type
  - The set of values that are valid for that type
  - The set of operations that are valid on those values
- An object is an instance of a type; it occupies memory, has an (optional) name and has a lifetime
- C++ is strongly and statically typed

### Type Regularity
- Regularity defines a set of properties a type should have
- Regular types are those that can be stored in standard containers (e.g. `std::vector<T>`)
  - Therefore standard algorithms should only use operations allowed for regular types
- *Concepts* are used to describe those properties required for a type T to be regular

### Semiregular Types
- These types are not strictly regular; it's a bit weaker than regular
- Copy constructor is a property of semiregular types
  - Used to initialise a variable `a` with an object of the same type `b`, e.g. `T a(b);` or `T a = b` (equivalent if `a` and `b` have the same type)

### Equivalence and Equality
- The semantics of the copy constructor are that `a` should be *equivalent* to `b` after copying
- Equivalence - mathematically speaking, a relation $R(a,b)$ is equivalent if it is:
  - Symmetric: $R(a,b) <=> R(b,a)$
  - Reflexive: $R(a,a)$
  - And transitive: $if\ R(a,b)\ and\ R(b,c)=>R(a,c)$
- However we want something stronger than equivalence; *equality*
- A copy is something equal but not identical to the original
  - After `a` is copy constructed from original `b`, then `a==b` for however we define this equality
  - But importantly they have distinct identities (in C++ case their location in memory will be different)
- All copy constructors must behave in the way that copied objects have equality

### Initialisation and Assignment
