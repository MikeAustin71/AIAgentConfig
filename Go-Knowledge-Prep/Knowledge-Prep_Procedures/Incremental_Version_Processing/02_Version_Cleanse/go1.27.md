---
title: Go 1.27 Release Notes
template: false
---

<style>
  main ul li { margin: 0.5em 0; }
</style>

## Introduction to Go 1.27 {#introduction}

The latest Go release, version 1.27, arrives in [August 2026](https://go.dev/doc/devel/release#go1.27.0), six months after [Go 1.26](https://go.dev/doc/go1.26).
Most of its changes are in the implementation of the toolchain, runtime, and libraries.
As always, the release maintains the Go 1 [promise of compatibility](https://go.dev/doc/go1compat).
We expect almost all Go programs to continue to compile and run as before.

## Changes to the language {#language}

<!-- go.dev/issue/77273 -->

Go 1.27 now supports [generic methods](https://go.dev/issue/77273):
a [method declaration](https://go.dev/ref/spec#Method_declarations) may declare its own
[type parameters](https://go.dev/ref/spec#Type_parameter_declarations).
This widely anticipated change allows adding generic functions within
the namespace of a particular data type where before one had to declare
such functions with a scope of the entire package.
As an example, `math/rand/v2` now also declares a generic method with signature
`(*Rand) N[Int intType](Int) Int`, whereas previously it had just a
generic function `N[Int intType](Int) Int` (see [below](#rand) for details).
Note that methods of [interfaces](https://go.dev/ref/spec#Interface_types) may not declare
type parameters nor can interface methods be implemented by generic methods.

<!-- go.dev/issue/9859 -->

A key in a [struct literal](https://go.dev/ref/spec#Composite_literals) may now be any
valid [field selector](https://go.dev/issue/9859) for the struct type, not just a
(top-level) field name of the struct.

<!-- go.dev/issue/77245 -->

Function type inference has been [generalized](https://go.dev/issue/77245) to apply in all
contexts where a generic function is [assigned](https://go.dev/ref/spec#Assignability) to a
variable of (or converted to) a matching function type.

## Tools {#tools}

<!-- go.dev/issue/77177 -->

Response file (`@file`) parsing is now supported for the `compile`, `link`, `asm`, `cgo`, `cover`, and `pack` tools.
The response file contains whitespace-separated arguments with support for single-quoted and double-quoted strings, escape sequences, and backslash-newline line continuation.
The format is compatible with GCC's response file implementation to ensure interoperability with existing build systems.

### Go command {#go-command}

<!-- go.dev/issue/78090 -->

The `go` command no longer has support for the `bzr` version control system.
It will no longer be able to directly fetch modules hosted on `bzr` servers.

#### `GODEBUG`

<!-- go.dev/issue/79422 -->

Starting with Go 1.27, the `go` command now recognizes a `GODEBUG` setting
for which support was removed (such as `asynctimerchan`, see [below](#runtime)) if it appears in `go.mod`
files (`godebug` entries) and `.go` source files (`//go:debug` comments).
It accepts these settings if they are set to the final default value established before
the setting was removed.
If they are set to an old value, the `go` command will fail.
This change is in the spirit of the [Go 1 compatibility guarantee](https://go.dev/doc/go1compat)
and allows existing programs that set supported `GODEBUG` settings to continue to
build and run without changes even when the respective setting support has been removed.

#### `go test`

`go test` now invokes the `stdversion` vet check by default.
This reports the use of standard library symbols that are too new
for the Go version in force in the referring file,
as determined by `go` directive in `go.mod` and build tags on the file.

<!-- go.dev/issue/62728 -->

`go test -json` now annotates `"Action":"output"` lines with an optional
new field `"OutputType"`, specifying the type of output.
Currently, the possible values include "error", "error-continue", and "frame".
See [cmd/test2json help](https://go.dev/cmd/test2json#hdr-Output_Format) for details.

#### `go doc`

<!-- go.dev/issue/63696 -->

The `go doc` command now supports `package@version` syntax, such as
`go doc example.com/pkg@v1.2.3`.

<!-- go.dev/issue/26715 -->

The `go doc` command now accepts the `-ex` command-line option to
list executable examples of the given package or symbol.
When an example name is passed on the command line (such as
`go doc bytes.ExampleBuffer`), `go doc` now prints the example source
code along with comments.

#### `go fix`

The `go fix` command contains several new modernizers (`atomictypes`, `embedlit`, `slicesbackward`, and `unsafefuncs`).

<!-- go.dev/issue/77581 -->

The existing `fmtappendf` analyzer was removed due to stylistic concerns.

The existing `waitgroup` analyzer was renamed to `waitgroupgo` to avoid ambiguity.

#### `go mod tidy`

<!-- go.dev/issue/56471 -->

For modules specifying `go 1.27` or later in their `go.mod` file, `go mod tidy`
now automatically merges duplicate require blocks. This ensures the file
maintains a clean, standard structure containing at most two require blocks:
one for direct dependencies and one for indirect dependencies.

Existing comment blocks attached to dependencies are preserved during this
consolidation. If a comment block is associated with a mixed set of directives
(containing both direct and indirect dependencies), the comment block is merged
and attached to the new direct dependency block.

Previously, if a `go.mod` file accumulated multiple disjoint require blocks
(often due to manual edits, unresolved Git merge conflicts, or legacy upgrades)
`go mod tidy` would leave the extra blocks intact or inadvertently create new
ones. The tool now strictly enforces the two-block layout, consolidating
disparate requirements into their respective blocks and cleaning up the
structure of the module file automatically.

### Trace

<!-- go.dev/issue/78921 -->

`go tool trace`'s `-http` command-line option now restricts the listen
address to localhost when passed only a port (e.g., `-http=:6060`).
This change makes `go tool trace` consistent with the behavior of
`go tool pprof`'s `-http` flag.
To listen on all addresses, explicitly include the specified address
(e.g., `-http=0.0.0.0:6060`).

## Runtime {#runtime}

<!-- CL 742580 -->

Tracebacks for modules with `go` directives configuring Go 1.27 or later will now
include [`runtime/pprof`](https://pkg.go.dev/runtime/pprof) goroutine labels in
the header line. This behavior can be disabled with `tracebacklabels=0` `GODEBUG` setting
(added in [Go 1.26](https://go.dev/doc/godebug#go-126)). This opt-out is expected to be
kept indefinitely in case goroutine labels acquire sensitive information that
shouldn't be made available in tracebacks.

<!-- CL 781580 -->

The `asynctimerchan` `GODEBUG` setting (added in [Go 1.23](https://go.dev/doc/godebug#go-123))
has been removed permanently. Channels created by package [time](https://pkg.go.dev/time)
are now always unbuffered (synchronous), irrespective of `GODEBUG` settings.

### Faster memory allocation

<!-- go.dev.issue/79286 -->

The compiler now generates calls to size-specialized memory allocation
routines, reducing the cost of some small (<80 byte) memory allocations by
up to 30%.
Improvements vary depending on the workload, but the overall improvement is
expected to be ~1% in real allocation-heavy programs.
This causes the binary size to increase by about 60 KB (independent of the
workload).
Please [file an issue](https://go.dev/issue/new) if you notice any regressions.
You may set `GOEXPERIMENT=nosizespecializedmalloc` at build time to disable
it.
This opt-out setting is expected to be removed in Go 1.28.

### Goroutine leak profile {#goroutineleak-profiles}

<!-- go.dev/issue/74609 -->

A new profile type that reports leaked goroutines, previously available
as an experiment in [Go 1.26](https://go.dev/doc/go1.26#goroutineleak-profiles), is now
generally available.
The new profile type, named `goroutineleak`, is supported in the
[`runtime/pprof`](https://go.dev/pkg/runtime/pprof) package.
It is also available as the [`net/http/pprof`](https://go.dev/pkg/net/http/pprof)
endpoint `/debug/pprof/goroutineleak`.

A *leaked* goroutine is a goroutine blocked on some concurrency primitive
(channels, [`sync.Mutex`](https://go.dev/pkg/sync#Mutex), [`sync.Cond`](https://go.dev/pkg/sync#Cond), etc)
that cannot possibly become unblocked.
The runtime detects leaked goroutines using the garbage collector: if a
goroutine G is blocked on concurrency primitive P, and P is unreachable from
any runnable goroutine or any goroutine that *those* could unblock, then P
cannot be unblocked, so goroutine G can never wake up.
While it is impossible to detect permanently blocked goroutines in all cases,
this approach detects a large class of such leaks.

Because this technique builds on reachability, the runtime may fail to identify
leaks caused by blocking on concurrency primitives reachable through global
variables or the local variables of runnable goroutines.

See [Go 1.26 release notes](https://go.dev/doc/go1.26#goroutineleak-profiles) for an example.

Special thanks to Vlad Saioc at Uber for contributing this work.

The `goroutineleakprofile` `GOEXPERIMENT` setting is now deleted.

## Compiler {#compiler}

The compiler now resolves a relative filename in a `//line` or `/*line*/`
directive against the directory of the file containing the directive,
matching the behavior of [`go/scanner`](https://go.dev/pkg/go/scanner).
Absolute filenames are unaffected.
See [#70478](https://go.dev/issue/70478).

<!-- go.dev/issue/60324, CL 770200 -->

The compiler now generates simpler names for function literals
(closures).
Previously, when the containing function is inlined, the function
literal's name can get quite long.
Now the compiler chooses the same name for the function literal
regardless of inlining.
It may also combine multiple instances of the same function literal
(as its containing function is inlined) to share the same code in
the compiled binary.
This change does not affect the functionality of Go code.
Tests that check symbol names may need update, although it is
recommended to not depend on the names of function literals.
For programs that [incorrectly](https://go.dev/pkg/reflect#Value.Pointer) compare
function code pointer for equality, the issue may be more exposed
with Go 1.27, as function literals with different captured closure
data may have equal code pointers in more cases.

## Linker {#linker}

<!-- CL 751260, go.dev/issue/58722 -->

When targeting macOS, the linker now accepts `-macos` and `-macsdk`
command-line options, which specify the OS and SDK versions in the
`LC_BUILD_VERSION` load command.
By default, it selects the oldest supported macOS version (currently
[13.0.0](#darwin)) and a recent SDK version (currently 26.2.0).

## Standard library {#library}

### New encoding/json/v2 and encoding/json/jsontext packages {#jsonv2}

<!-- go.dev/issue/71497 -->

Two new packages are now available:

  - The [`encoding/json/v2`](https://go.dev/pkg/encoding/json/v2) package is a major
    revision of [`encoding/json`](https://go.dev/pkg/encoding/json). It provides
    [`Marshal`](https://go.dev/pkg/encoding/json/v2#Marshal),
    [`MarshalWrite`](https://go.dev/pkg/encoding/json/v2#MarshalWrite),
    [`MarshalEncode`](https://go.dev/pkg/encoding/json/v2#MarshalEncode),
    [`Unmarshal`](https://go.dev/pkg/encoding/json/v2#Unmarshal),
    [`UnmarshalRead`](https://go.dev/pkg/encoding/json/v2#UnmarshalRead), and
    [`UnmarshalDecode`](https://go.dev/pkg/encoding/json/v2#UnmarshalDecode),
    all of which accept variadic [`Options`](https://go.dev/pkg/encoding/json/v2#Options)
    arguments to configure marshaling and unmarshaling behavior.

  - The [`encoding/json/jsontext`](https://go.dev/pkg/encoding/json/jsontext) package
    provides lower-level syntactic processing of JSON.
    The [`Encoder`](https://go.dev/pkg/encoding/json/jsontext#Encoder) and
    [`Decoder`](https://go.dev/pkg/encoding/json/jsontext#Decoder) types operate on
    JSON as a sequence of
    [`Token`](https://go.dev/pkg/encoding/json/jsontext#Token) and
    [`Value`](https://go.dev/pkg/encoding/json/jsontext#Value),
    maintaining a state machine to ensure the produced or consumed
    sequence is valid JSON text.

The v2 package chooses stricter, more interoperable defaults than v1:
it rejects invalid UTF-8 in JSON strings and rejects duplicate names within
a JSON object. See the v1 [`encoding/json`](https://go.dev/pkg/encoding/json#hdr-Migrating_to_v2) package
documentation for the complete set of behavioral differences and
the options available to adjust them.

The [`encoding/json`](https://go.dev/pkg/encoding/json) package is now backed by the
v2 implementation. Marshaling and unmarshaling behavior is preserved, but
the exact text of error messages may differ. The package also gains a number of
new [`Options`](https://go.dev/pkg/encoding/json#Options) that can configure v2 to operate
with v1 semantics to avoid requiring a full migration to the new API.
The v1 API will continue to be supported and users are not required to migrate.

Marshal performance is broadly at parity with the previous implementation,
while unmarshal performance is significantly faster.

Users who encounter compatibility problems with the new implementation
may disable it by setting `GOEXPERIMENT=nojsonv2` at build time,
restoring the original v1 implementation.
This opt-out is expected to be removed in a future release.

Some notable changes to `encoding/json/v2` over the course of the `GOEXPERIMENT` include
the following removals:
the `format` tag option ([#79071](https://go.dev/issue/79071)),
the `unknown` tag option ([#77271](https://go.dev/issue/77271)),
the `DiscardUnknownMembers` marshal option ([#77271](https://go.dev/issue/77271)),
and the `SkipFunc` sentinel error ([#74324](https://go.dev/issue/74324)).
In addition, the `inline` tag option was renamed to `embed` ([#79985](https://go.dev/issue/79985)), and
behavior was updated for the [`string`](https://go.dev/pkg/encoding/json/v2#hdr-JSON_Representation_of_Go_structs)
tag option ([#79065](https://go.dev/issue/79065))
and the [`MatchCaseInsensitiveNames`](https://go.dev/pkg/encoding/json/v2#MatchCaseInsensitiveNames)
option ([CL 792780](/cl/792780)).
In `encoding/json/jsontext`, the numeric [`Token`](https://go.dev/pkg/encoding/json/jsontext#Token)
accessors were changed to also return errors ([#77666](https://go.dev/issue/77666)).

See the [proposal issue](https://go.dev/issue/71497) for background and additional detail.
If you need to disable the new implementation, [please file an issue](https://go.dev/issue/new).

### New crypto/mldsa package {#crypto_mldsa}

<!-- https://go.dev/issue/77626, https://go.dev/issue/78888 -->

The new [`crypto/mldsa`](https://go.dev/pkg/crypto/mldsa) package implements the post-quantum ML-DSA signature
scheme specified in FIPS 204.

[`crypto/x509`](https://go.dev/pkg/crypto/x509) now supports ML-DSA private keys, public keys, and signatures.

[`crypto/tls`](https://go.dev/pkg/crypto/tls) now supports ML-DSA signatures in TLS 1.3, with the new
[`MLDSA44`](https://go.dev/pkg/crypto/tls#MLDSA44), [`MLDSA65`](https://go.dev/pkg/crypto/tls#MLDSA65),
and [`MLDSA87`](https://go.dev/pkg/crypto/tls#MLDSA87) [`SignatureScheme`](https://go.dev/pkg/crypto/tls#SignatureScheme) values.

### New uuid package {#uuid}

<!-- https://go.dev/issue/62026 -->

The new [`uuid`](https://go.dev/pkg/uuid) package generates and parses UUIDs.


### New experimental simd package {#simd}

Go 1.27 introduces a new experimental [`simd`](https://go.dev/pkg/simd)
package that provides portable and vector-size-agnostic SIMD
support. It will make use of the hardware instructions
if they are available.
This package is enabled by setting the environment variable
`GOEXPERIMENT=simd` at build time.

The `simd` package is available on all architectures, and provides
vector types of unspecified size such as [`Int8s`](https://go.dev/pkg/simd#Int8s) and [`Float32s`](https://go.dev/pkg/simd#Float32s).
It supports a "scalable" subset of the operations present in the
[`simd/archsimd`](https://go.dev/pkg/simd/archsimd) package
that are hardware-supported or easily emulated across architectures
and vector widths.

See the [proposal issue](https://go.dev/issue/78902) for more details.

### Experimental simd/archsimd package {#archsimd}

Go 1.27 continues the experimental support for SIMD operations in
the [`simd/archsimd`](https://go.dev/pkg/simd/archsimd/) package that began in [Go 1.26](https://go.dev/doc/go1.26#simd).
This release revises the amd64 API and adds support for arm64 "Neon" 128-bit SIMD and WebAssembly 128-bit SIMD.
The `simd/archsimd` package is enabled by setting the environment variable
`GOEXPERIMENT=simd` at build time.

This package provides access to architecture-specific SIMD operations.
It supports 128-bit vector types on wasm, arm64, and amd64,
and 256-bit and 512-bit vector types on some amd64 processors.
The API is not yet considered stable.

See the [package documentation](https://go.dev/pkg/simd/archsimd) and the [proposal issue](https://go.dev/issue/73787) for more details.

We intend to provide support for additional architectures in future versions, but the
API is intentionally architecture-specific and thus non-portable.

### Minor changes to the library {#minor_library_changes}

#### [`bytes`](https://go.dev/pkg/bytes/)

<!-- 6-stdlib/99-minor/bytes/71151.md -->

The new [`CutLast`](https://go.dev/pkg/bytes#CutLast) function slices a `[]byte`
around the last occurrence of a separator.
It can replace and simplify some common uses of [`LastIndex`](https://go.dev/pkg/bytes#LastIndex).

#### [`compress/flate`](https://go.dev/pkg/compress/flate/)

<!-- go.dev/issue/75532, CL 707355 -->

Compression speed is improved in Go 1.27.
The exact encoded output from [`Writer`](https://go.dev/pkg/compress/flate#Writer) may be different from Go 1.26
as a result of the encoder implementation change.
Since DEFLATE is the underlying compression used in [`archive/zip`](https://go.dev/pkg/archive/zip), [`compress/gzip`](https://go.dev/pkg/compress/gzip), [`compress/zlib`](https://go.dev/pkg/compress/zlib), and [`image/png`](https://go.dev/pkg/image/png),
the outputs from those packages may also have changed.

#### [`crypto`](https://go.dev/pkg/crypto/)

<!-- 6-stdlib/99-minor/crypto/77626.md -->

The new [`MLDSAMu`](https://go.dev/pkg/crypto#MLDSAMu) [`Hash`](https://go.dev/pkg/crypto#Hash) value
is added for use as a signaling mechanism for External μ ML-DSA signing.

#### [`crypto/ecdsa`](https://go.dev/pkg/crypto/ecdsa/)

<!-- 6-stdlib/99-minor/crypto/ecdsa/hashlen.md -->

[`PrivateKey.Sign`](https://go.dev/pkg/crypto/ecdsa#PrivateKey.Sign) now checks that the length of the hash is correct,
if a non-nil [`SignerOpts`](https://go.dev/pkg/crypto#SignerOpts) is provided.

#### [`crypto/tls`](https://go.dev/pkg/crypto/tls/)

<!-- 6-stdlib/99-minor/crypto/tls/77363.md -->

The new [`QUICConfig.ClientHelloInfoConn`](https://go.dev/pkg/crypto/tls#QUICConfig.ClientHelloInfoConn) field specifies the [`net.Conn`](https://go.dev/pkg/net#Conn) to use
for the [`ClientHelloInfo.Conn`](https://go.dev/pkg/crypto/tls#ClientHelloInfo.Conn) field during QUIC server handshakes.

<!-- 6-stdlib/99-minor/crypto/tls/78543.md -->

The [`MLKEM1024`](https://go.dev/pkg/crypto/tls#MLKEM1024) key exchange is now supported. It can be enabled by adding it to
[`Config.CurvePreferences`](https://go.dev/pkg/crypto/tls#Config.CurvePreferences).

<!-- 6-stdlib/99-minor/crypto/tls/78888.md -->
<!-- crypto/tls ML-DSA support is documented in doc/next/6-stdlib/70-mldsa.md. -->

<!-- 6-stdlib/99-minor/crypto/tls/79367.md -->

[`Config.Rand`](https://go.dev/pkg/crypto/tls#Config.Rand) is now deprecated.
For deterministic testing, use [`testing/cryptotest.SetGlobalRandom`](https://go.dev/pkg/testing/cryptotest#SetGlobalRandom).

<!-- 6-stdlib/99-minor/crypto/tls/tlsmlkem.md -->

Post-quantum hybrid key exchanges can now be explicitly enabled in
[`Config.CurvePreferences`](https://go.dev/pkg/crypto/tls#Config.CurvePreferences) even if the `tlsmlkem=0` or `tlssecpmlkem=0` `GODEBUG`
options are used. Those options were always meant to only apply to the default
set used when [`Config.CurvePreferences`](https://go.dev/pkg/crypto/tls#Config.CurvePreferences) is nil.

<!-- go.dev/issue/24673 -->

The new [`ConnectionState.LocalCertificate`](https://go.dev/pkg/crypto/tls#ConnectionState.LocalCertificate)
field contains the certificate chain presented to the connection peer during the handshake.

<!-- go.dev/issue/75316 -->

The `tlsunsafeekm` (added in [Go 1.22](https://go.dev/doc/godebug#go-122)),
`tlsrsakex` (added in [Go 1.22](https://go.dev/doc/godebug#go-122)),
`tls3des` (added in [Go 1.23](https://go.dev/doc/godebug#go-123)),
`tls10server` (added in [Go 1.22](https://go.dev/doc/godebug#go-122)),
and `x509keypairleaf` (added in [Go 1.23](https://go.dev/doc/godebug#go-123))
`GODEBUG` settings have been removed permanently.

<!-- go.dev/issue/72111 -->

The `tlskyber` `GODEBUG` setting (added in [Go 1.23](https://go.dev/doc/godebug#go-123))
was removed in [Go 1.24](https://go.dev/doc/godebug#go-124) but the removal was not
documented in the [release notes for Go 1.24](https://go.dev/doc/go1.24.md) at that time;
it is documented now.

#### [`crypto/x509`](https://go.dev/pkg/crypto/x509/)

<!-- 6-stdlib/99-minor/crypto/x509/75260.md -->

When parsing into [`pkix.Name`](https://go.dev/pkg/crypto/x509/pkix#Name) fields,
a wider range of [`pkix.AttributeTypeAndValue.Value`](https://go.dev/pkg/crypto/x509/pkix#AttributeTypeAndValue.Value)
types is now supported, and unknown types are parsed into
[`asn1.RawValue`](https://go.dev/pkg/encoding/asn1#RawValue).

<!-- 6-stdlib/99-minor/crypto/x509/76133.md -->

The new [`Certificate.RawSignatureAlgorithm`](https://go.dev/pkg/crypto/x509#Certificate.RawSignatureAlgorithm), [`CertificateRequest.RawSignatureAlgorithm`](https://go.dev/pkg/crypto/x509#CertificateRequest.RawSignatureAlgorithm),
and [`RevocationList.RawSignatureAlgorithm`](https://go.dev/pkg/crypto/x509#RevocationList.RawSignatureAlgorithm) fields expose the DER-encoded
AlgorithmIdentifier of the signature algorithm, including when the
SignatureAlgorithm field is [`UnknownSignatureAlgorithm`](https://go.dev/pkg/crypto/x509#UnknownSignatureAlgorithm).

<!-- 6-stdlib/99-minor/crypto/x509/77865.md -->

[`SystemCertPool`](https://go.dev/pkg/crypto/x509#SystemCertPool) now respects SSL_CERT_FILE and SSL_CERT_DIR on Windows and
Darwin. When these environment variables are set, roots are loaded from disk and
instead of using the platform certificate verification APIs, the native Go
verifier is used. This behavior can be disabled with
`GODEBUG=x509sslcertoverrideplatform=0`.

<!-- 6-stdlib/99-minor/crypto/x509/78888.md -->
<!-- crypto/x509 ML-DSA support is documented in doc/next/6-stdlib/70-mldsa.md. -->

#### [`crypto/x509/pkix`](https://go.dev/pkg/crypto/x509/pkix/)

<!-- 6-stdlib/99-minor/crypto/x509/pkix/33093.md -->

[`RDNSequence.String`](https://go.dev/pkg/crypto/x509/pkix#RDNSequence.String) (and therefore [`Name.String`](https://go.dev/pkg/crypto/x509/pkix#Name.String)) now renders string-typed
attribute values as strings even when the attribute's OID is unrecognized.
Previously such values were always hex-encoded in their DER form.
See [#33093](https://go.dev/issue/33093).

#### [`database/sql`](https://go.dev/pkg/database/sql/)

<!-- 6-stdlib/99-minor/database/sql/67546.md -->

The new [`ConvertAssign`](https://go.dev/pkg/database/sql#ConvertAssign) function gives database drivers access
to the type conversions performed by [`Rows.Scan`](https://go.dev/pkg/database/sql#Rows.Scan).

#### [`database/sql/driver`](https://go.dev/pkg/database/sql/driver/)

<!-- 6-stdlib/99-minor/database/sql/driver/67546.md -->

Drivers may implement the new [`RowsColumnScanner`](https://go.dev/pkg/database/sql/driver#RowsColumnScanner) interface
to scan directly into user-provided destinations.

#### [`go/constant`](https://go.dev/pkg/go/constant/)

<!-- 6-stdlib/99-minor/go/constant/79042.md -->

The new [`StringLen`](https://go.dev/pkg/go/constant#StringLen) function returns
the length of a string [`Value`](https://go.dev/pkg/go/constant#Value) without
fully constructing the `Value`.

#### [`go/scanner`](https://go.dev/pkg/go/scanner/)

<!-- 6-stdlib/99-minor/go/scanner/74958.md -->

The scanner now allows retrieving the end position of a token via the new [`Scanner.End`](https://go.dev/pkg/go/scanner#Scanner.End) method.

#### [`go/token`](https://go.dev/pkg/go/token/)

<!-- 6-stdlib/99-minor/go/token/76285.md -->

[`File`](https://go.dev/pkg/go/token#File) now has a `String` method.

#### [`go/types`](https://go.dev/pkg/go/types/)

<!-- 6-stdlib/99-minor/go/types/69420.md -->

The [`Hasher`](https://go.dev/pkg/go/types#Hasher) type is an implementation of
[`maphash.Hasher`](https://go.dev/pkg/maphash#Hasher) for [`Type`](https://go.dev/pkg/go/types#Type)s
that respects the [`Identical`](https://go.dev/pkg/go/types#Identical) equivalence relation, allowing `Types`
to be used in hash tables and similar data structures.
[`HasherIgnoreTags`](https://go.dev/pkg/go/types#HasherIgnoreTags) is the analogous hasher for [`IdenticalIgnoreTags`](https://go.dev/pkg/go/types#IdenticalIgnoreTags).

<!-- 6-stdlib/99-minor/go/types/76472.md -->
<!-- CL 736441 -->

The `gotypesalias` `GODEBUG` setting (added in [Go 1.22](https://go.dev/doc/godebug#go-122))
has been removed permanently and the package [`go/types`](https://go.dev/pkg/go/types)
now always produces an [`Alias`](https://go.dev/pkg/go/types#Alias) type node for
[alias declarations](https://go.dev/ref/spec#Alias_declarations) irrespective of `GODEBUG` settings.

<!-- 6-stdlib/99-minor/go/types/79287.md -->
<!-- nothing to see here but some String methods -->

#### [`hash/maphash`](https://go.dev/pkg/hash/maphash/)

<!-- 6-stdlib/99-minor/hash/maphash/70471.md -->

The [`Hasher`](https://go.dev/pkg/hash/maphash#Hasher) interface type defines the contract between values of a
particular type and future hash-based data structures such as hash
tables and Bloom filters; see [#70471](https://go.dev/issue/70471).

The [`ComparableHasher`](https://go.dev/pkg/hash/maphash#ComparableHasher) type provides a
convenient implementation of [`Hasher`](https://go.dev/pkg/hash/maphash#Hasher) for
comparable types where the `Equal` method is defined as `==`.

#### [`math/big`](https://go.dev/pkg/math/big/)

<!-- 6-stdlib/99-minor/math/big/76821.md -->
<!-- go.dev/issue/76821 -->

[`Int`](https://go.dev/pkg/math/big#Int) now has a [`Divide`](https://go.dev/pkg/math/big#Int.Divide) method
to compute quotient and remainder of two [`Int`](https://go.dev/pkg/math/big#Int) values.
It supports rounding modes [`Trunc`](https://go.dev/pkg/math/big#Trunc), [`Floor`](https://go.dev/pkg/math/big#Floor),
[`Round`](https://go.dev/pkg/math/big#Round), and [`Ceil`](https://go.dev/pkg/math/big#Ceil).

#### [`math/rand/v2`](https://go.dev/pkg/math/rand/v2/) {#rand}

<!-- 6-stdlib/99-minor/math/rand/v2/77853.md -->

[`Rand`](https://go.dev/pkg/math/rand/v2#Rand) now supports a generic method
[`N`](https://go.dev/pkg/math/rand/v2#Rand.N),
matching the behavior of the top-level [`N`](https://go.dev/pkg/math/rand/v2#N) function.

#### [`net`](https://go.dev/pkg/net/)

<!-- 6-stdlib/99-minor/net/78137.md -->

[`UnixConn`](https://go.dev/pkg/net#UnixConn) read methods now return [`io.EOF`](https://go.dev/pkg/io#EOF) directly instead of wrapping it in [`net.OpError`](https://go.dev/pkg/net#OpError) when the underlying read returns EOF.

#### [`net/http`](https://go.dev/pkg/net/http/)

<!-- 6-stdlib/99-minor/net/http/21753.md -->

[`Transport`](https://go.dev/pkg/net/http#Transport) and [`Server`](https://go.dev/pkg/net/http#Server) support TLS ALPN protocol negotiation on
user-provided [`net.Conn`](https://go.dev/pkg/net#Conn) connections which implement a
`ConnectionState() tls.ConnectionState` method.

<!-- 6-stdlib/99-minor/net/http/75500.md -->

HTTP/2 server now accepts client priority signals, as defined in RFC 9218,
allowing it to prioritize serving HTTP/2 streams with higher priority. If the
old behavior is preferred, where streams are served in a round-robin manner
regardless of priority, [`Server.DisableClientPriority`](https://go.dev/pkg/net/http#Server.DisableClientPriority) can be set to `true`.

<!-- 6-stdlib/99-minor/net/http/77370.md -->

HTTP/1 [`Response.Body`](https://go.dev/pkg/net/http#Response.Body) now automatically drains any unread content upon being
closed, up to a conservative limit, to allow better connection reuse. For most
programs, this change should be a no-op, or result in a performance improvement.
In rare cases, programs that do not benefit from connection reuse might
experience performance degradation if they had been improperly allowing an
excessive amount of idle connections to linger; usually by setting
[`Transport.MaxIdleConns`](https://go.dev/pkg/net/http#Transport.MaxIdleConns) to `0` or using different [`Client`](https://go.dev/pkg/net/http#Client)s for different
requests, thereby bypassing [`Transport.MaxIdleConns`](https://go.dev/pkg/net/http#Transport.MaxIdleConns) limit. In these cases,
setting [`Transport.DisableKeepAlives`](https://go.dev/pkg/net/http#Transport.DisableKeepAlives) to `true` will disable connection reuse.
However, such performance degradation usually indicates improper configuration
or usage of [`Transport`](https://go.dev/pkg/net/http#Transport) or [`Client`](https://go.dev/pkg/net/http#Client) in the first place, and a deeper look would
likely be beneficial.

<!-- go.dev/issue/79936 -->

The new [`Server.MaxHeaderValueCount`](https://go.dev/pkg/net/http#Server.MaxHeaderValueCount)
field allows HTTP servers to control the number of header values that they are
willing to accept. If unset,
[`DefaultMaxHeaderValueCount`](https://go.dev/pkg/net/http#DefaultMaxHeaderValueCount) is
used.

#### [`net/http/httptest`](https://go.dev/pkg/net/http/httptest/)

<!-- 6-stdlib/99-minor/net/http/httptest/76608.md -->

The new [`NewTestServer`](https://go.dev/pkg/net/http/httptest#NewTestServer) function
creates a [`Server`](https://go.dev/pkg/net/http/httptest#Server) configured to use an in-memory
fake network suitable for use with the [`testing/synctest`](https://go.dev/pkg/testing/synctest) package.

#### [`net/url`](https://go.dev/pkg/net/url/)

<!-- 6-stdlib/99-minor/net/url/73450.md -->

The new [`URL.Clone`](https://go.dev/pkg/net/url#URL.Clone) method creates a deep copy of a URL.
The new [`Values.Clone`](https://go.dev/pkg/net/url#Values.Clone) method creates a deep copy of Values.

#### [`runtime/secret`](https://go.dev/pkg/runtime/secret/)

Goroutines that are created while in [secret mode](https://go.dev/pkg/runtime/secret#Do)
will now themselves execute in secret mode.

#### [`strings`](https://go.dev/pkg/strings/)

<!-- 6-stdlib/99-minor/strings/71151.md -->

The new [`CutLast`](https://go.dev/pkg/strings#CutLast) function slices a string
around the last occurrence of a separator.
It can replace and simplify some common uses of [`LastIndex`](https://go.dev/pkg/strings#LastIndex).

#### [`syscall`](https://go.dev/pkg/syscall/)

<!-- CL 750680 -->

On Plan 9, the [`Errno`](https://go.dev/pkg/syscall#Errno) type is now defined and
implements the `error` interface, as on other platforms. Plan 9 system
calls return `ErrorString` values, so `Errno` is never returned by this
package on Plan 9. It is defined so that portable code referring to
`syscall.Errno` builds on Plan 9 without build constraints.

#### [`testing/synctest`](https://go.dev/pkg/testing/synctest/)

<!-- 6-stdlib/99-minor/testing/synctest/77169.md -->

The new [`Sleep`](https://go.dev/pkg/testing/synctest#Sleep) helper function combines [`time.Sleep`](https://go.dev/pkg/time#Sleep) and [`synctest.Wait`](https://go.dev/pkg/testing/synctest#Wait).

#### [`unicode`](https://go.dev/pkg/unicode/)

<!-- 6-stdlib/99-minor/unicode/77266.md -->

The unicode package and associated support throughout the system have been upgraded from Unicode 15 to Unicode 17.
See the [Unicode 16.0.0](https://www.unicode.org/versions/Unicode16.0.0/) and
[Unicode 17.0.0](https://www.unicode.org/versions/Unicode17.0.0/)
release notes for information about the changes.

## Ports {#ports}

### Darwin {#darwin}

<!-- go.dev/issue/75836 -->

As [announced](go1.26#darwin) in the Go 1.26 release notes,
Go 1.27 requires macOS 13 Ventura or later;
support for previous versions has been discontinued.

### PowerPC {#ppc64}

<!-- go.dev/issue/76244 -->

On the big-endian 64-bit PowerPC port on Linux (`GOOS=linux` `GOARCH=ppc64`),
the Go toolchain now generates binaries that use the ELFv2
system ABI.
ELFv2 support requires Linux kernel 3.13 or later.
RHEL7 backported this support to its 3.10 kernel.

Cgo, position-independent executables (PIE), and external linking
are now supported.
Using these features requires an ELFv2 compatible runtime
(libc and all linked and loaded libraries).

For programs that do not use cgo, the Go toolchain still
generates static binaries with internal linking by default.
For programs that have cgo options, if a static, pure-Go binary
is needed, one can set the environment variable `CGO_ENABLED=0`
when running `go build`.
