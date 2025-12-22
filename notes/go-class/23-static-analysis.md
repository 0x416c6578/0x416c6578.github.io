## Static Analysis (Video 37)
- The idea behind static analysis is to inspect code and find bugs / enhancements before even running it - *compile time analysis*
- `gofmt` comes under this umbrella, Go has a well defined style guide that IDEs will format to automatically on save
- `goimports` will update / clean import lists which is also useful
- `golint` checks for non-format style issues, e.g. exported names having comments for `godoc`, `panic` not being used for normal error handling, error flow indented, happy path not etc.
  - Rules for `golint` come from *Effective Go* and Google
- `go vet` is another standard tool that will apply certain rules to look for suspicious things, e.g. accidentally copying mutexes, possibly invalid integer shifts, struct tags, atomic assignments and unreachable code etc.
  - It would find the issue in `fmt.Printf("%s\n", 20)`
- There are many other static analysis tools, however we can't assume they are always right, there may be false positives:
  - `goconst` for finding literals that should be declared with `const`
  - `gosec` for finding possible security vulnerabilities
  - `ineffassign` to find assignments that are ineffective (e.g. shadowed)
  - `gocyclo` to find high cyclomatic complexity in functions
  - `deadcode`, `unused`, `varcheck` to find unused or dead code
  - `unconvert` to find redundant type conversions

### `ineffassign` Example
- Ineffectual assignment to `err`:

```go
prices, err := r.prices(region)
regularPrices, err := r.regularPrices(region)

if err != nil {
    return nil, fmt.Errorf("price not available for region %s", region)
}
```

- The `ineffassign` tool would point this out as a risk since the first err is never checked because it is shadowed

### `golangci-lint`
- Is an all in one tool that will raise linting issues which must be fixed for a build to pass
- You can ignore false positive scans with `//nolint`
