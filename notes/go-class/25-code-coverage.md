## Code Coverage (Video 39)
- We can use the `-cover` flag for `go test` to get coverage information from our tests
- Using `-coverprofile=c.out -covermode=count` we can get an output file that contains coverage information, most importantly a count of how many times specific statements are called
- `go tool cover -html=c.out` can then be used to analyse the output; it will show your code in a heatmap of how much was covered
- Coverage should be used to guide testing, it shouldn't be used as a target to hit e.g. 90% or whatever
