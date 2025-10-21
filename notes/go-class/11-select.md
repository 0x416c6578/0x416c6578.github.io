## Select (Video 24)
- The `select` statement is used to multiplex channels, allowing any *ready* alternative to proceed among:
  - A channel we can read from
  - A channel we can write to
  - A default action that is always *ready*
- Selects are used to compose channels as synchronisation primitives, things like mutexes can't be composed
- Selects often tend to be run in a loop so that we can keep trying
- It is common to put a timeout or "done" channel into a select
- Example:

```go
func main() {
  chans := []chan int{
    make(chan int),
    make(chan int)
  }

  for i := range chans {
    go func(i int, ch chan<- int) {
      for {
        time.Sleep(time.Duration(i)*time.Second)
        ch<- i
      }
    }(i+1, chans[i])
  }

  for i := 0; i < 12; i ++ {
    // Select allows us to listen to both channels at the same time, and whichever
    // one is ready first will be read
    select {
    case m0 := <-chans[0]:
      fmt.Println("received", m0)
    case m1 := <-chans[1]:
      fmt.Println("received", m1)
    }
  }
}
```

- As mentioned a common pattern is to have a stopper channel that will be a separate select case that will trigger the select to stop waiting on any stuck channels
- We can do this using the `time.After` function
- `time.After(5*time.Second)` will create a new timer, this timer has a channel which is returned by this function. The timer will send the current time on this channel when the timer elapses
- This can be used in a select statement to trigger a timeout scenario for example
- There also exists `time.Ticker` which is similar but will tick indefinitely with a given tick rate

### Default Case
- In select blocks, the `default` case is already and is chosen if no other case is ready
- You shouldn't put a default in a select in a loop - this will cause busy waiting and high CPU usage
- An example pattern of using a default:

```go
func sendOrDrop(data []byte) {
  select {
  case ch <- data;
    // sent ok; do nothing
  default:
    log.Printf("overflow, dropped %d bytes", len(data))
  }
}
```

- In this example if the channel is ready to receive data, it will send the data as expected
- In the case that the channel can't receive data, the default case is run and a log message is sent