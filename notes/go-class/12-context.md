## Context (Video 25)
- The context package allows you to tie together some related work, allowing a common method to cancel some work either explicitly or implicitly with a timeout or deadline
- Contexts can also carry request specific values like key trace IDs
- A context offers two controls:
  - A `Done` channel that closes when the cancellation occurs
  - An error that is readable once the channel closes
- The error value will tell you whether the request was cancelled or timed out
- This `Done()` channel is often used in select blocks

### The Context Tree
- Contexts form an **immutable** tree structure
- Cancellation or timeout applies to the current context and its subtree (and the same for values assigned in a context)
- For example with timeouts, the thing doing the work will look up from the bottom of the tree (up towards the empty `context.Background` top level context) for any timeout contexts
  - Subtrees may be created with a shorter timeout, but not longer

```go
ctx := context.Background()
ctx = context.WithValue(ctx, "traceId", "abc123")
ctx, cancel := context.WithTimeout(ctx, 3 * time.Second)
defer cancel() // it is common to defer cancel

req, _ := http.NewRequest(http.MethodGet, url, nil)
req = req.WithContext(ctx)
resp, err := http.DefaultClient.Do(req)
```

- Above is an example of setting up a context with a value and a timeout for an HTTP request
- The HTTP client will manage the timeout, and will return an error if a timeout occurs before the request completes
- There are two different mechanisms for timing out - a timeout (e.g. timeout in 5 seconds) and a deadline (e.g. timeout at 15:00pm)
- An example in the video outlined using a context for requesting a number of URLs
- It outlined an important aspect of using channels - we need to make sure that we have mechanisms in place to prevent Goroutines from hanging indefinitely
  - In the example, an unbuffered channel was used in a set of running Goroutines that all send a result
  - This meant that one Goroutine would write to the channel successfully, but the others would be blocked
  - A way of solving this is to close the channel, or to use a buffered channel that allows all the Goroutines to send successfully
- It also raised another issue of, if we are passed in a context into a function that we are writing, we need to ensure we handle the case of a parent caller issuing a cancel (the context becoming `Done()`)
  - This can be done in your `select`, then you can see the error in `ctx.Err()`

### Context With Values
- Contexts can be used to pass around values, e.g. trace IDs or start times (for latency calculation), or security or auth data
- Context values have keys - to ensure the keys don't clash we can define a package specific private context key type (not string) to avoid collisions:

```go
type contextKey int

// Make sure the keys are exported (but not the type itself), then clients have a single source of truth for requesting context values without the risk of collision
const (
  TraceIdContextKey contextKey = iota
  StartTimeContextKey contextKey
  AuthContextKey contextKey
)
```

- Below is an example of some HTTP middleware to add a trace ID

```go
func AddTrace(next http.Handler) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()

    if traceID := r.Header.Get("X-Trace-Context"); traceID != "" {
      ctx = context.WithValue(ctx, TraceIdContextKey, traceID)
    }

    next.ServeHTTP(w, r.WithContext(ctx))
  })
}

func LogWithContext(ctx context.Context, f string, args ...any) {
   // reflection is required because the context values "map" can contain any. We need
   // to downcast the any to a string (this two argument cast will return ok=true if
   // the conversion was a success). More on reflection later ;)
  traceID, ok := ctx.Value(TraceIdContextKey).(string)

  // adding the trace ID to the log message if it is in the context
  if ok && traceID != "" {
    f = traceID + ": " + f
  }

  log.Printf(f, args...)
}
```

- One of Go's philosophies is to make everything as explicit as possible, so it's important not to abuse the context value tree too much