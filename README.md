# mruby-dap-client

A DAP (Debug Adapter Protocol) client library for mruby.

## Responsibility

This gem implements the transport and client-side state used to communicate
with a debug adapter. It is independent of mrbmacs and mruby-specific source
debugging.

`DAP::Client`:

- starts an adapter with `IO.popen` or `spawn`, or connects to a Unix or TCP
  socket;
- frames JSON messages with DAP `Content-Length` headers;
- sends requests and matches responses by sequence number;
- receives asynchronous DAP events;
- stores adapter capabilities and source breakpoints.

UI behavior belongs to clients such as
[`mruby-mrbmacs-dap`](https://github.com/masahino/mruby-mrbmacs-dap).
Translation between mruby source-level operations and a native debugger belongs
to [`mruby-bin-dap-proxy`](https://github.com/masahino/mruby-bin-dap-proxy).

## Adapter startup

The adapter command, arguments, connection port, socket path, and adapter type
are supplied when creating `DAP::Client`. With no port or socket path, the
adapter is started with bidirectional standard I/O. Adapter standard error is
written to a logfile.

The client currently builds a command string from the configured command and
arguments. Command lookup and argument interpretation therefore depend on the
host environment.

## Installation

Add the gem to `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  conf.gem github: 'masahino/mruby-dap-client'
end
```

## License

MIT. See `LICENSE`.
