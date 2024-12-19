defmodule SWTPM do
  @moduledoc """
  Software TPM emulator.
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
