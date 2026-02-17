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
- Equivalence - mathematically speaking, a relation `R(a,b)` is equivalent if it is:
  - Symmetric: `R(a,b) <=> R(b,a)`
  - Reflexive: `R(a,a)`
  - And transitive: `if\ R(a,b)\ and\ R(b,c)=>R(a,c)`
- However we want something stronger than equivalence; *equality*
- A copy is something equal but not identical to the original
  - After `a` is copy constructed from original `b`, then `a==b` for however we define this equality
  - But importantly they have distinct identities (in C++ case their location in memory will be different)
  - It is important that it is *not identical*; we can't have sharing since that would break the *copy* constructor semantics
- All copy constructors must behave in the way that copied objects have equality

### Initialisation and Assignment
- Semiregular types also have an assignment operator; `T a; a = b;` -> the assignment operator is the `=`
- When we use the assignment operator we assign `a` to an object which is equal to `b`
- Construction (initialisation) and assignment must me equivalent; `T a1(b)` and `T a2; a2 = b` should always yield `a1 == a2`
- The difference between initialisation and assignment is that initialisation creates the initial state for a new object, whereas assignment must first clean up the old state of an existing object then initialises it's new state
- In order for these semantics to hold, we also need an `==` operator to be defined for the objects; how else would you otherwise decide if two instances are equal??
  - Regular types have an `==` (and by extension `!=`) operator defined for them

### Regular Types
- `==` is the required function of regular types
- `==` must be symmetric

### Total Orderings
- You can't sort regular types, therefore a concept `TotallyOrdered` is defined which extends `Regular` by adding the comparison operator `<`
- `<` must obey the properties:
  - Anti-reflexive; `a` can never be `<` `a`
  - Transitive
  - Anti-symmetric; if `a<b` then `b` can never be `<` `a`
  - If `a!=b` then `a<b` or `a>b`
- The semantics of `<` are bound to the sematics of equality and related operations; e.g. if `a >= b` then `a` cannot be `<` `b`
- `<=>` is a helper operator that returns <0 if `a<b`, >0 if `a>b` and returns 0 when `a==b`. We can define this one function and the compiler will auto generate all the other functions for us

### Destructors
- Are called by the compiler automatically when an object falls out of scope; they end the lifetime of an object

### Java vs C++ Semantics in Detail
- C++ has copy semantics; when you assign or pass objects a copy is made
  - By default, copy constructors in C++ are shallow; if your object is managing a pointer then the pointer in the new copied object will be pointing to the same memory as the old one; this is dangerous
    - Otherwise C++ auto generated copy constructors just copy every field of the old object to the new object (calling the copy constructors of each field respectively)
  - You can use references in C++ (`&`) to get reference semantics similar to Java
- Java has reference semantics; when you assign or pass objects (_not_ primitives), then the new object will reference the same old object, meaning that modifications on the new object will also change the old one

### C++ Classes
- Classes and structs in C++ are basically identical except classes have default private visibility and structs have default public

### Singleton
- In this example a singeton is just a one element container; like a pair but with only one guy
- It uses templates which are losely equivalent to generics in other languages
- A template is a type function

```cpp
template <typename T>
struct singleton
{
    T value;
}
```

#### Compiler Generated Functions
- The compiler generates 6 functions for you when you make a user defined type
  1. Default constructor
    - Constructor for a type with no additional arguments (e.g. `singleton<int> s;`)
    - 
  2. Destructor
    - When an object goes out of scope
  3. Copy constructor
    - E.g. `singleton<int> s1 = s`
  4. Copy assignment
    - Used whenever an existing instance of a user defined type is assigned to another instance of that type; e.g. `singleton<int> s2; s2 = s1`
  5. Move constructor
  6. Move assignment
- These functions are defined recursively; e.g. the copy constructor will call the copy constructor on each member field

### Semi-regular singleton
- Remember semi regularity has a copy constructor and copy assignment

```cpp
struct singleton {
    T value;
    
    singleton() {}
    ~singleton() {}
    
    // copy constructor
    singleton(singleton const& x) 
        : value(x.value) {
          
    }
    
    // copy assignment
    singleton& operator=(singleton const& x) {
        value = x.value;
        return *this;
    }
}
```

- We could just do `= default;` for these function definitions to use the compiler generated functions (which would have the same semantics as above)
- **Important** - the default constructor is always synthesised **only if** you haven't defined any other constructors; it won't be constructed if you have any other constructors defined
