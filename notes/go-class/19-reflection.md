## Reflection (Video 33)
### `interface{}`
- The empty interface has no methods, and so it can represent anything
- It is a generic thing, but we sometimes need to downcast it to a real type
- Go has first class support for reflection

```go
var w io.Writer = os.Stdout
f := w.(*os.File) // success
c := w.(*bytes.Buffer) // failure since the interface holds a *os.File not a *bytes.Buffer
```

- Above shows an example of downcasting an interface to a specific type
- Downcasting comes from inheritance hierarchies, and in the context of Go might not be the correct term, instead *type assertion* is more correct
- There is also a two argument version that will return true or false for success or failure, rather than panicking as the above example would do

```go
c, ok := w.(*bytes.Buffer)
```

- Reflection is used a lot in the standard library, for example in `fmt` and `json`

```go
func Println(args ...interface{}) {
    // ...
    for _, arg := range args {
        switch a := arg.(type) {
            case string: // concrete type
                // do something with the string
            case Stringer: // interface
                // call the String() method on the interface to get the string representation
        }
    }
}
```

- The above example shows using reflection to switch on type. `a` takes on a value of the type it is, and when the case matches, a will have that corresponding type, meaning we can do things like call the methods on that `Stringer` interface

### DeepEqual
- In Go, slices can't be directly compared with `==`
- If we have a struct with an embedded slice, we can use `reflect.DeepEqual` to do a reflection based equals that will look into slices and other normally non-comparable structures to check for equality

```go
want := struct{
    someSlice := []int{1,2,3}
}

got := someFunction()

if !reflect.DeepEqual(got, want) {
    fmt.Println("failed equality check")
}
```

### Reflection in JSON Unmarshalling
- The Go JSON library uses reflection extensively to deserialise (unmarshal in Go terminology) JSON
- For example we can define custom unmarshallers that will unmarshal some messy badly designed JSON like

```json
{
    "item": "album",
    "album": {"title": "Quality Over Opinion"}
}
{
    "item": "song",
    "song": {"title": "Shallow Laughter", "artist": "Louis Cole"}
}
```

- Into a struct like

```go
type Response struct {
    Item string
    Album string
    Title string
    Artist string
}
```

- Code isn't here but we'd define a custom unmarshaller that would first unmarshal into a `map[string]any` then have logic for extracting the fields conditionally as required

#### Custom Unmarshaller Caveat
- When defining a custom unmarshaller for a custom struct (e.g. for adding in additional logic that default unmarshalling can't do), you need to make sure to define a wrapper type for your incoming type so that recursive unmarshalling doesn't happen: 

```go
type Person struct {
    Name string `json:"name"`
}

func (p *Person) UnmarshalJSON(data []byte) error {
    // uh oh stinky, this will recursively unmarshal
    return json.Unmarshal(data, p)
}

func (p *Person) UnmarshalJSON(data []byte) error {
    type wrapper Person
    // we make a new variable aux which is a wrapper type. The pointer points to the same underlying memory
    // of p, however in the type system the UnmarshalJSON method isn't defined for the wrapper type
    // and so we can call json.Unmarshal without issues. Then we can do any custom validation we want to
    aux := (*wrapper)(p)

    if err := json.Unmarshal(data, aux); err != nil {
        return err
    }

    // custom validation / logic
    if p.Name == "" {
        return errors.New("missing name")
    }

    return nil
}
```

- The above example shows the issue of recursive unmarshalling and how to fix it (very easy really just an interesting caveat to know of)
