## Concurrency In Go (Video 23)
### Channels Overview
- Channels are one-way communication pipes where writers write values in and readers read values out
- They are thread safe data structures, meaning multiple writers and readers can share it safely
- Channels act as a synchronisation point that allows multiple independent processes to communicate safely
  - The idea of channels and Goroutines in Go is based off Hoare's _Communicating Sequential Processes_

### Goroutines Overview
- Goroutines are the unit of independent execution in Go. They are started by putting the `go` keyword in front of a function call
- Goroutines **aren't OS threads**, they are lightweight userspace threads that are scheduled onto a number of real OS threads. This lightweight design means Go can schedule thousands of Goroutines with little overhead
- Channels are used to synchronise Goroutines. We know that a send (write) to a channel always _happens before_ a receive (read)
- Channels will block if you attempt to read from an empty channel
  - Channels will also block if you attempt to read from a nil channel
  - Channels will instantly return `(zeroVal, nok)` if they are closed and you try to read

### `http.HandlerFunc` Channel Pattern
- An interesting pattern can be established using channels in a method receiver. If we wanted to have a channel that is directly used by a handler that conforms to `http.HandlerFunc`'s signature, we _could_ use a global variable, however this isn't a great idea since global variables aren't great
- So instead we can create a named type for the channel, then attach a method to the channel that has the correct signature:

```go
type intCh chan int

func (ch intCh) handler(w http.ResponseWriter, r *http.Request) {
  fmt.Fprintf(w, "Received %d from channel", <-ch)
}
```

- Now instead of having the channel as a global variable, we can instead use a method value: `http.HandleFunc("/", someIntCh.handler)`
- Isn't Go neat?!

### Prime Sieve Example

<figure>
<img loading="lazy" width="500" src="../../Images/go-tutorial/primeSieve.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=zJd7Dvg3XCk">https://www.youtube.com/watch?v=zJd7Dvg3XCk</a>
</figcaption>
</figure>

```go
// generates numbers up to the given limit and writes them to a channel, closing the channel when finished
func generate(limit int, ch chan<- int) {
    defer close(ch)
    for i := 2; i < limit; i++ {
        ch <- i
    }
}

// receives numbers from a channel and filters for only those not divisible by the given 
// divisor, writing to a destination channel and closing the destination when the src is closed
func filter(src <-chan int, dst chan<- int, divisor int) {
    defer close(dst)
    for i := range src { // Will block until a value is added to src, and break when src is closed
        if i%divisor != 0 {
            dst <- i
        }
    }
}

// prime sieving function
func sieve(limit int) {
    ch := make(chan int)
    go generate(limit, ch) // kicks off generator

    for {
        prime, ok := <-ch
        if !ok {
            break // we are done
        }

        // makes a new filter for the prime that was just seen, then adds it to the chain of running filters
        newFilterChan := make(chan int)
        go filter(ch, newFilterChan, prime)
        ch = newFilterChan

        fmt.Print(prime, " ")
    }
}

func main() {
    sieve(1000)
}
```

- Above is an example of the prime sieve algorithm, which will construct new prime filters when a prime is seen, adding it to a chain of filters
  - When the generator stops generating the channel closing will cascade through the filters stopping their goroutines before finally causing the sieve function to complete
  - This is a very inefficient algorithm but it is a good example of using channels