## HTTP and Networking in Go (Video 15)
- `net/http` is the standard library package for HTTP networking
- The core interface in this library for handling requests is 

```go
type Handler interface {
  ServeHTTP(http.ResponseWriter, *http.Request)
}
```

- The library also defines a helper method on functions with that signature that makes them conform to the Handler interface:

```go
type HandlerFunc func(ResponseWriter, *Request)

// This is a method declaration on a function type
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
  f(w, r)
}

// Then we can define a function that conforms to that interface without 
// requiring explicit implementation of ServeHTTPz§
func handler(w http.ResponseWriter, r *http.Request) {
  fmt.Fprintf(w, "Hello, world")
}
```

- Go allows methods to be put on any declared type, including functions as is the case in the above example
- `http.Template` is a package for doing HTTP templating

```go
var form = `
<h1>Todo #{{.ID}}</h1>
<div>{{printf "User %d" .UserID}}</div>
```

- Above is an example of a template string for the `http.Template` library to populate. It uses double bracket syntax for templating and has directives like `printf` to do formatting. It will pull values from the fields specified in the template, e.g. pulling the ID from the `.ID` field of some struct
- More reading / work on HTTP bits will be done in the future