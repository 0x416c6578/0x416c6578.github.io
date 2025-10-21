## Structs and JSON (Video 12)
- Structs are an aggregate of multiple types of named fields

```go
type Employee struct {
  Name string
  Number int
  Boss *Employyee
  Hired time.Time
}
```

- You can use the printf (`%+v`) to pretty print a struct and it's fields

### Maps of Structs
- You can store maps of structs (e.g. `map[string]MyStruct`) however it is really bad practice to do this because a map's internal structure is dynamic
  - Instead it is recommended to store a map of pointers to structs (e.g. `map[string]*MyStruct`)
- You also can't perform mutation operations (e.g. `++`) on fields of structs by direct access (e.g. `myMap["thing"].IntField++`)
  - This is because the semantics of maps are that they are meant to store _values_ not references, so when you access a value in a map by it's key, you get a _copy_ of the value meaning you can't directly mutate it and have the map update

### Structure & Name Compatibility of Structs
- Anonymous structs with the same field names and types (**and tags**) are treated as being the same type by the compiler
- However when you give a struct a name with `type blah struct{...}`, that no longer is the case - structs with different names will always be different types even if they have the same field names and types
- You can convert structs if they have the same structure:

```go
type thing1 struct {
	field int
}
type thing2 struct {
	field int
}
func main() {
	a := thing1{field: 1}
	b := thing2{field: 1}
	a = thing1(b) // Valid
}
```

- The zero value of a struct is the zero value of all of it's fields
  - This is a core Go concept - make the zero value useful
- Structs are copied, so when they are passed in as parameters to functions a copy is made and modifications will only be made on the copy
- The dot notation for fields also works on pointers, e.g. for `thing *myStruct`, `thing.field` is equivalent to dereferencing `(*thing).field`
  - This is different to C/C++ where you'd use -> for accessing or mutating a field in a struct pointer
- Structs with no fields are useful - they take up no space
  - Some uses include creating a set (`map[int]struct{}`) or creating a `chan struct{}` to be a "complete" notifier without the need to pass any data if that isn't needed
  - The empty struct is a singleton - it is the sentinel value used to indicate an empty slice

### JSON with Structs
- Struct tags are key value pairs that can be attached to a struct field
- They can specify how struct fields should be serialised / deserialised by libraries (done with reflection)

```go
type Response struct {
  Data string `json:"data"` // Only exported fields are included in a marshalled JSON string
  Status int `json:"status"`
}

func main() {
  // Serializing
  r := Response{"Some data", 200}
  j, _ := json.Marshal(r)

  // j will be []byte containing "{"data":"Some data","status":200}"

  // Deserializing
  var r2 Response
  _ = json.Unmarshal(j, &r2)
}
```