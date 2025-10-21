## Conventional Synchronisation (Video 28)
- Sometimes it is useful to use more conventional synchronisation primitives in code if you need finer grained control over things
- The aim of synchronisation is for mutual exclusion; to make sure only one Goroutine can run in the critical section at a time
- The most basic sync primitive is the lock
  - Acquire the lock before accessing data
  - Any other Goroutine will block whilst waiting for the lock
  - Release the lock when done

```go
func do() int {
  m := make(chan bool, 1)

  var n int64
  var w sync.WaitGroup

  for i := 0; i < 1000; i++ {
    w.Add(1)

    go func() {
      m <- true
      n++  // this would be a data race, however the channel here acts like a lock (a counting semaphore of count 1 is a lock)
      <-m
      w.Done()
    }()
  }

  w.Wait()
  return int(n)
}
```

- The above example shows off how a channel can be used as a lock to ensure only one Goroutine can access it's critical section at a time
  - The reason this is a race condition is that if two goroutines try to `n++` at the same time, one of the increments can be lost
- Of course this basically removes all concurrency from this toy example
- We can change m to a `sync.Mutex` and change to using `m.Lock()` and `m.Unlock()` to get the equivalent behaviour using a more explicit mutex

### Mutexes
- As mentioned previously, mutexes are basically things you can lock and unlock in a threadsafe manner
- It is common to embed a mutex into some other type and make it part of the operations on that type

```go
type SafeMap struct {
  sync.Mutex
  m map[string]int
}

func(s *SafeMap) Incr(key string) {
  s.Lock()
  defer s.Unlock() // useful habit to defer unlock
  s.m[key]++
}
```

#### RWMutex
- The RWMutex is an enhancement of the traditional mutex
- It will allow many readers to hold the lock at the same time
  - When you lock for writing, all readers are blocked, but when locked for reading all the other readers are ok
  - Another writer will be blocked of course
- This mutex is used when you have some data that is read heavy

### `sync.atomic`
- `sync.atomic` offers some hardware dependent atomic operations like atomic add, CAS etc.
- Mostly used for very low level operations that aren't really used in most Go programs

### `sync.Once`
- This can ensure a function runs only once (e.g. for the singleton pattern)

```go
var once sync.Once
var x *someSingleton

func initSingleton() {
  x = NewSingleton()
}

func handle(w http.ResponseWriter, r *http.Request) {
  once.Do(initSingleton)
  //...
}
```

- `once.Do` ensures `initSingleton` runs only once
  - Just checking `if x == nil` and assigning isn't threadsafe!!

### `sync.Pool`
- `sync.Pool` is a way to store a threadsafe pool of objects that can be used for reuse

```go
var bufPool = sync.Pool {
  New: func() any {
    return new(bytes.Buffer)
  },
}

func Log(w io.Writer, key, val string) {
  b := bufPool.Get().(*bytes.Buffer) // reflection
  b.Reset()
  // use b
  w.Write(b.Bytes())
  bufPool.Put(b) // return b to the pool
}
```

- The `New` function in the struct is called whenever `Get()` is called and there are no objects in the pool to use (in this case it just creates and returns a new byte buffer)

___

- There are some other synchronisation primitives available

## Homework (Video 29)
- This video explains a race condition in an HTTP server and how to go about fixing it
- One of the ways you can detect races in Go is using the race detector (`go run -race .`)
- The race condition was caused by unsafe concurrent use of the Go map
- To fix the race condition, a mutex was used to make concurrent use of the map safe