## More on Channels (Video 26)
- Channels will block unless ready to read or write
  - For writing, channels block unless they have buffer space or there is at least one reader ready to read (called rendezvous)
  - For reading, channels block unless they have unread data in their buffer or at least one writer is ready to write. Closed channels always read instantly (zero value and a nok open flag)
    - Nil channels block indefinitely - this can be useful behaviour for disabling select cases
- You can constrain channels in arguments to read / write:

```go
func get(url string, ch chan<- result) { }
func collect(ch <-chan result) map[string]int { }
```

### Closed Channels
- Closing a channel is often a signal that work is done
- Channels can only be closed once (or else panic)
- As mentioned, closed channels become readable with the default value
- Coordinating closing of channels is another problem in itself
- Importantly, a buffered channel will not indicate it is closed until all values buffered are read out of it

### Nil Channels
- As mentioned, nil channels always block so in a select they are effectively ignored
- They also block indefinitely when writing to
- This is useful because you can *suspend* a channel by changing it to nil, then unsuspend it by reassigning
- But it is important to always close a channel when there is logically no more input, e.g. EOF

<figure>
<img loading="lazy" width="500" src="../../Images/go-tutorial/channels states.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=fCkxKGd6CVQ">https://www.youtube.com/watch?v=fCkxKGd6CVQ</a>
</figcaption>
</figure>

- The above is a useful table of different channel states and their corresponding behaviour
  - The bottom two rows are for the static read only / write only channels outlined previously

### Rendezvous Model
- By default channels are unbuffered
- This creates a rendezvous model where goroutines will synchronise on a write / read
  - Since reading / writing blocks until a writer / reader is ready to write / read

<figure>
<img loading="lazy" width="500" src="../../Images/go-tutorial/channel sync.png" alt="" style="border:1px solid black;"/>
<figcaption style="font-style: italic;">
Reproduced from <a href="https://www.youtube.com/watch?v=fCkxKGd6CVQ">https://www.youtube.com/watch?v=fCkxKGd6CVQ</a>
</figcaption>
</figure>

- The above diagram shows this synchronisation
  - See how the sender doesn't return (unblock) until the receiver is finished receiving
  - This causes a nice two way synchronisation where both the sender and receiver know that the other has received / sent
- Remember this is just for unbuffered channels, where the channel is used as a synchronisation tool

### Buffering
- Buffering works a bit differently, the buffer allows a sender to send without waiting (until the buffer is full)
- The sender and receiver can run independently; no synchronisation point occurs

### Important Note
- It is important to never modify things after you have written them to a channel

```go
type T struct {
  i byte
  b bool
}

func send(i int, ch chan<- *T) {
  t := &T{i: byte(i)}
  ch<- t
  t.b = true // NEVER DO THIS
}

func main() {
  vs := make([]T, 5)
  ch := make(chan *T)
  for i := range vs {
    go send(i, ch)
  }

  time.Sleep(1*time.Second)

  // This quick copy will read and copy the values written into the channel by
  // the 5 running goroutines. But there is a race condition so the value of t.b
  // for all the values is false since it is likely (but not guaranteed) that this
  // read and copy will finish before the t.b is updated in the goroutine. If the
  // channel was buffered, it would be likely (but again not a guarantee) that 
  // the value is true for all. The time.Sleep() will almost guarantee that this
  // is the case but again this is a race condition so it should never be relied upon
  for i := range vs {
    vs[i] = *<-ch
  }

  for _,v :+ range vs {
    fmt.Println(v)
  }
}
```

### Why Buffering
- Buffering is useful to avoid leaked goroutines (since all channels have a space to write to) and also it avoids the rendezvous pauses when buffered channels synchronise
- However buffering can hide race conditions so it is important to consider buffering use until it is required