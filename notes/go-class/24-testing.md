## Testing (Video 38)
- Go conventions are for files ending in `_test.go` for test files, holding `TestXXXX` functions (this is similar to the `BenchmarkXXXX` functions for benchmarking)
- Tests are run with `go test`
  - Tests aren't run if the source wasn't changed since the last test

### Layers of Testing
- There are different layers of testing that can be done by developers and testers
- From the top down, we have different types of testing, with the line being drawn somewhere in *end-to-end* between that which is done by testers and that which is done by developers
  - Chaos testing
  - System testing
  - Performance / load testing
  - End-to-end testing
  - Integration testing
  - Unit testing
- Testing at the developer level can cover many different things:
  - Extreme values
  - Input validation
  - Race conditions
  - Error conditions
  - Boundary conditions
  - Pre and post conditions
  - Randomised data (fuzzing)
  - Configuration and deployment
  - External interfaces to other software
- Developer testing is transparent and fully automated; as developers we know stuff about the software that we can test

### Test Functions
- Test functions have the same signature:

```go
func TestCrypto(t *testing.T) {
  // do some tests

  if err != nil {
    t.ErrorF("failed test: %s", err)
  }
}
```

- `testing.T` is something you can report errors on

### Subtests
- We can run subtests under a parent using `t.Run()`

```go
func SomeTest(t *testing.T) {
  table := []struct {
    name string
    param int
    outcome int
  }{
    {name: "test1", param: 1, outcome: 10},
    {name: "test2", param: 3, outcome: 30},
  }
}

for _, st := range table {
  t.Run(st.name, func(t *testing.T) {
    // do the test here
  })
}
```

- Now we can have nice named subtests parameterised

#### Nicer Subtest / Parameterised Testing Pattern
- These functions can become a bit cumbersome, so an approach was outlined in the video that looks as follows:

```go
// this is the function we are testing
func someFunctionToTest(input string) bool {
  return len(input) < 5
}

// we define a named type for our parameterised test
type parameterisedTest struct {
  name  string
  input string
  want  bool
}

// we define a run method which we use as our input to t.Run
func (pt parameterisedTest) run(t *testing.T) {
  got := someFunctionToTest(pt.input)
  if pt.want != got {
    t.Errorf("input %v, wanted %v, got %v", pt.input, pt.want, got)
  }
}

// we define our table of tests
var tests = []parameterisedTest{
  {name: "happy", input: "hi", want: true},
  {name: "boundary 1", input: "hello", want: true},
  {name: "boundary 2", input: "helloo", want: false},
}

// now everything is nicely separated in our actual test and is easier to follow
func TestSomeFunctionToTest(t *testing.T) {
  for _, pt := range tests {
    t.Run(pt.name, pt.run)
  }
}
```

- `pt.run` is a method value! It's the run method bound to `pt` which is the particular parameterised test we are running!
- Super neat pattern!!!

#### Checker Refactoring for Subtests
- We can also parameterise how we check results using a checker interface:

```go
type checker interface {
  check(*testing.T, string, string) bool
}

type subTest struct {
  name string
  shouldFail bool
  checker checker
}

type checkGolden struct { /*...*/ }

func (c checkGolden) check(t *testing.T, got, want string) bool {
  // implement checking logic here
}
```

### Mocking / Faking
- We can define mocks / fakes for things like database interfaces

```go
type DB interface {
  GetThing(string) (string, error)
}

var errShouldFail = errors.New("db should fail")
type mockDB struct {
  shouldFail bool // our mock DB can have forced fail scenarios for testing
}

func (m mockDB) GetThing(key string) (string, error) {
  // mockDB now conforms to the DB interface
  if m.shouldFail {
    // we can force an error case when the flag is set
    return thing{}, fmt.Errorf("%s: %w", key, errShouldFail)
  }
}
```

- We can use things like in-memory Redis things for testing, whereas for things like Postgres it's less easy to have an in-memory version because of the complexity of the implementations
