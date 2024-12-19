defmodule SWTPM do
  @moduledoc """
  Software TPM emulator.
  """

  @doc """
  Integrates the `SWTPM` module with a supervision tree, providing a
  standardized way to configure and start the Software TPM emulator as a
  supervised process.

  ## Options
  - `:state_dir` - Specifies the directory where the TPM state will be stored.

  - `:server_port` - Specifies the TCP port used for the TPM server. Defaults
    to `2321`.

  - `:ctrl_port` - Specifies the TCP port used for TPM control commands.
    Defaults to `2322`.

  - `:flags` - Refer to https://man.archlinux.org/man/swtpm.8.en for full list
    of flags. Defaults to `[:not_need_init, :startup_clear]`.

  ## Example
  ```elixir
  children = [
    {SWTPM, [state_dir: "/data/tpm"]}
  ]

  Supervisor.start_link(children, [strategy: :one_for_one, name: MySupervisor])
  ```
  """
  @spec child_spec(term) :: Supervisor.child_spec()
  def child_spec(opts) do
    state_dir   = opts[:state_dir]
    server_port = opts[:server_port] || 2321
    ctrl_port   = opts[:ctrl_port] || 2322

    flags =
      Keyword.get(opts, :flags, [:not_need_init, :startup_clear])
      |> Enum.map(& to_string(&1) |> String.replace("_", "-"))
      |> Enum.join(",")

    MuonTrap.Daemon.child_spec([
      Path.join([:code.priv_dir(:swtpm), "bin", "swtpm"]),
      [
        "socket",
        "--tpm2",
        "--tpmstate", "dir=#{state_dir}",
        "--server",   "type=tcp,port=#{server_port}",
        "--ctrl",     "type=tcp,port=#{ctrl_port}",
        "--flags",    flags
      ]
    ])
  end
end
