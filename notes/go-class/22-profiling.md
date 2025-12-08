## Profiling (Video 36)
- The profiler is a useful way of determining long term program behaviour, allowing you to see things like running goroutines etc.
- Pprof is the profiler in Go. You can include it in your program with `include _ "net/http/pprof"` - the underscore is required since we aren't using anything from the package we just want it to be bound in our HTTP handler as an endpoint that we can go to and see our program profiler output
  - This only works when you are using the standard HTTP library, using another mux line gorillamux would require some extra work
- It is good practice to test your code before pushing it - one way is to see whether you are spawning goroutines and not closing them (e.g. blocking indefinitely on a channel or not closing a request body etc.)

### Prometheus
- Prometheus is a systems and service monitoring package that allows for more comprehensive and detailed metrics about your running Go program (and many other languages)
- You can define custom metrics and it will produce more detailed metrics
- See video for a good example of CPU profiling using a pixel drawing program - the idea is to look at the critical path of your program from the profiler output and identify optimisations in the code that could improve things