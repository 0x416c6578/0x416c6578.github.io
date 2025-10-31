## Mechanical Sympathy (Video 34)
- Optimisation of software systems can be thought of at different layers / levels of top-down refinement
1. Architecture (cloud vs bare metal, latency etc.)
2. Design (algorithms, concurrency, layers of abstraction)
3. Implementation (programming language, memory use)
- Mechanical sympathy plays a role in the *implementation*, and is about making software that works *with* the machine, not against it
  - Basically making software suck less
- This idea only really relates to compiled languages, interpreted less so 

### Memory Caching
- The cost of computational work is driven by the cost of reading memory
- CPUs have caches built in that help improve efficiency 
- Caching imposes some cost
  - Memory access by the cache line, typically 64 bytes wide (this is the unit of data read from main memory, not 1 byte but 64)
  - Multi core caches require cash coherency mechanisms to ensure no race conditions - this is done in hardware
- Caches exploit locality
  - In space - if you use something you're likely to use something next to it
  - In time - access implies we're likely to access again soon
- Caching is most effective when we use entire cache lines, and when we access memory in predictable patterns
- To get our best performance, we should keep things in contiguous memory and access them sequentially
- Non sequential access patterns are things like calling functions, and chasing pointers
- Calling lots of short methods via dynamic dispatch (which Go uses to determine which method to call on an interface) is very expensive and is a code smell; usually implying too many layers of abstraction
- Synchronisation has two costs - the cost to synchronise and the impact of contention (creating a hot spot)

### False Sharing
- False sharing occurs when we have two variables that are being used by two different cores, where both variables are on the same cache line
- Since we can't have two cores writing to the same cache line at the same time, the cache is invalidated
- This is made worse when the variables are heavily accessed - caching is thrown out the window and we have to use main memory which is slower
- This is difficult to spot since there won't be a code-level race condition between the variables, it just happens that they sit in the same cache line and the hardware synchronisation of this slows things down

### Other Hidden Costs
- Disk access, GC, virtual memory and it's cache, context switching between processes
- The only real thing you can control is GC - reduce unnecessary allocations, reduce embedded pointers in objects
- Sometimes you actually want a larger heap 
