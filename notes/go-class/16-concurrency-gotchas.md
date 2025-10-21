## Concurrency Gotchas (Video 30)
### Race Conditions
- Where unprotected reads and writes overlap

### Deadlock
- When no goroutine can make progress
  - E.g. all goroutines are blocked on empty channels
  - Or all goroutines could be blocked waiting on a mutex
  - Or GC could be prevented from running (busy loop)
- Go can detect *some* deadlocks automatically, and can detect *some* data races with `-race`

### Goroutine Leaks
- When a goroutine hangs on an empty or blocked channel but there isn't deadlock; other goroutines can still make progress
- Can be found by looking at `pprof` output
- It is important to always know how / when a goroutine will end when you write it

```go
func main() {
  ch := make(chan obj)

  go func() {
    // some long non blocking work...
    ch <- something
  }()

  select{
  case rslt := <-ch:
    fmt.Println(rslt)
  case <-time.After(timeout):
    fmt.Println("Timed out")
  }
}
```

- In the above example, if the timeout occurs before the channel is written to, then that goroutine will hang since the channel is unbuffered
- A fix for this is to use a buffered channel

### Channel Errors
- E.g. sending on a closed channel, sending or receiving on a nil channel, closing a nil channel or closing a channel twice

### Other Misc Errors
- Closure variable capture
- Misuse of `Mutex`, `WaitGroup` or `select`
- There is a good overview of Go concurrency errors that can be found at [https://cseweb.ucsd.edu/~yiying/GoStudy-ASPLOS19.pdf](https://cseweb.ucsd.edu/~yiying/GoStudy-ASPLOS19.pdf)

### Dining Philosophers
- Outlines a common problem with using mutex and mutex-adjacent concurrency control primitives
- We have two philosophers both of whom need a knife and a fork to eat their food
- There is only one knife and fork on the table, and each one simultaneously picks up one of the two
- Now they are both waiting on each other for the other to finish their food, which will never happen, thus they are deadlocked
- This can be seen as two processes that must acquire two locks to proceed, but if they both acquire one lock each, they are both deadlocked
- This can be fixed by making sure the locking is done in the same order by both processes, since then we know that if one has the first lock, then the other cannot have the second (since they both acquire the locks in some order, but crucially both acquire them in the same order)
  - Solving this problem is non trivial, and is one of the drawbacks of mutexes

### Incorrect Use of Waitgroup
- Logically you must always `Add()` to a waitgroup before starting the unit of work that calls `Done()`, otherwise `wg.Wait()` could return prematurely
- You should never add to a waitgroup in the goroutine itself

### A Bit More on Select
- Various things to remember: default is always active, nil channels are always ignored, full channels are always skipped over (for cases of sending to a channel in a select), and **all available channels are selected at random** (meaning no *done* channel is given preference)

### Useful Takeaways
- Don't start goroutines without knowing how they will stop
- Acquire locks / semaphores as late as possible, releasing them in the reverse order of obtaining (which is the semantics of `defer`)
- Don't wait for non-parallel work you can do yourself