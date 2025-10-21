## Concurrency (Finally!) (Video 22)
### Defining Concurrency
- A key idea in concurrent programming is the idea of a partial order
- In the example below, there is a partial ordering shown; parts of 2 and 3 have no direct ordering between each other (but they do have an ordering among themselves), however there is an _overall_ requirement that parts 2 and 3 complete before part 4
  
<figure>
<img loading="lazy" width="500" src="../../Images/go-tutorial/partialOrder.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=A3R-4ZYBqvE">https://www.youtube.com/watch?v=A3R-4ZYBqvE</a>
</figcaption>
</figure>

- Therefore this can execute in many different ways:

```
{1,2a,2b,3a,3b,4}
{1,2a,3a,2b,3b,4}
{1,2a,3a,3b,2b,4}
{1,3a,3b,2a,2b,4}
{1,3a,2a,2b,3b,4}
{1,3a,2a,3b,2b,4}
```

- None of these orders are wrong, it just means that the program behaves differently on different runs even with the same input

### Concurrency vs Parallelism
- We can define concurrency as: *Parts of the program may execute independently in some non-deterministic (partial) order*
  - Note this **does not** imply parallelism; concurrent programs can run on a single CPU (using task scheduling/interrupts), however modern day CPUs tend to have more than one core so most concurrent programs are inherently parallel if required
- Concurrency importantly doesn't necessarily make the program faster; parallelism does
  - Although interrupts can speed up programs because the main task can continue running whilst waiting for some external IO for example
- Concurrency is an aspect of how the software is written and put together, parallelism is something that happens at runtime for a concurrent program that can run across multiple cores

### Race Conditions
- Race conditions are bugs. They occur when the out of order non deterministic computations of a concurrent program might produce invalid results; one of the possible orders of execution may be wrong
  - They occur when concurrent operations change shared things
- For example if you are concurrently updating a balance on a bank account, you must make sure the read-modify-write operation is atomic, either through a data type that supports this or through mechanisms like mutexes