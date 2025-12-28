## Go Modules (Video 40)
- Modules were created to handle dependency management
- The aim was to remove the need for vendoring (including the source code of another project in the source of your own)
  - Although Go still supports vendoring where required
- It supports semantic versioning which ensures compatibility between specific versions of packages
- Go's dependency management protects against some risks:
  - Flaky repos, disappearing packages, conflicting dependency versions or surreptitious changes to packages
- It can't ensure the actual quality or security of the original code though

### Import Compatibility
- If an old and a new package have the same import path then the new package must be backwards compatible with the old one
  - Incompatible packages should use a new URL (version) (e.g. `json/v2`)
  - That way both can be imported if required for phased migration / transitions from old to new libraries

### Modules In Detail
- `go.mod` is the file that contains the module name along with direct dependency requirements (and from Go 1.13 the version of Go used as well)

```go
module hello // the module name
require github.com/x v1.1 // dependencies
go 1.13 // go version
```

- The `go.sum` file has checksums for all dependencies, including all _transitive_ dependencies
- Both should be checked into source control
- There are environment variables `GOPROXY` to specify the proxy server URL(s), `GOSUMDB` to specify the checksum database
- Private modules can also be used (e.g. in a corporate environment), these have other settings that can be configured
  - Of course you also need access to those private repositories to pull the dependencies
