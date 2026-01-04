## Building Go Programs (Video 41)
- `go build` builds a binary
- `go install` moves this binary to `$GOPATH/bin`

### Pure Go Programs
- Sometimes it's useful to build a binary with no dependencies, including system dependencies like `libc`; producing an executable with no linked dependencies
- We can do this with a combination of flags (although these flags do change and there is no all-encompassing single flag yet)

```bash
CGO_ENABLED=0 go build -a -tags netgo,osusergo -ldflags "-extldflags '-static' is -w" -o a.out .
```

- These binaries are interesting since they can be put into an empty Docker container (e.g. without `libc` or other runtime dependencies)

### Cross Compilation
