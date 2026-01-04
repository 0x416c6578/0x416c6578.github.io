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
  - In some respects it represents the *transitive closure* of all your 
- Both **must** be checked into source control
- There are environment variables `GOPROXY` to specify the proxy server URL(s), `GOSUMDB` to specify the checksum database
- Private modules can also be used (e.g. in a corporate environment), these have other settings that can be configured
  - Of course you also need access to those private repositories to pull the dependencies
- All Go modules are source based - there are no precompiled modules
- Modules and checksums are all cached as you would expect

### More Details
- If a module has no specific releases / tags in their repository, then Go will use a pseudo version comprising of a timestamp and commit hash
- In the case of a broken or vulnerable module, a `replace` directive might be needed which will point to a compatible but fixed version that Go builds will use

### Maintaining Dependencies
- A new Go project can be created with `go mod init module-name`, this will create the `go.mod` file
- `go build` will update the `go.mod` file
- Once a version is set, Go will not update automatically
  - You can update transitively with `go get -u`
  - `go mod tidy` will remove unneeded modules, should be done after `go get -u`
- To list available versions of a dependency use `go list -m -versions module-name`
- You can update a single dependency with `go get example.com/module@latest`, or `@v1.6.3` for a specific version
- Finally you can clean the module cache with `go clean -modcache` if required
