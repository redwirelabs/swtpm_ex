# swtpm

An easy way to bring a Software TPM emulator into your elixir application by
wrapping [swtpm](https://github.com/stefanberger/swtpm).

## Prerequisites

Ensure the following are installed on your host system:
* [libtasn1](https://www.gnu.org/software/libtasn1/)
* [json-glib-1.0](https://wiki.gnome.org/Projects/JsonGlib)
* [libseccomp](https://github.com/seccomp/libseccomp)
* [gmp](https://gmplib.org/)

## Installation

The package can be installed by adding `swtpm` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:swtpm, "~> 0.1.0"}
  ]
end
```

## Supervision

Add the `SWTPM` module spec to your `application.ex`. For more details see docs
for `&SWTPM.child_spec/1`.

```elixir
defp children(:host) do
  [
    {SWTPM, [state_dir: "data/tpm"]}
  ]
end
```
