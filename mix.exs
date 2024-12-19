defmodule SWTPM.MixProject do
  use Mix.Project

  @app :swtpm

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.16",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      compilers: [:cmake] ++ Mix.compilers(),
      releases: [{@app, release()}],
      dialyzer: [
        list_unused_filters: true,
        plt_file: {:no_warn, plt_file_path()},
      ],
      preferred_cli_env: [
        espec: :test,
      ],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

  defp aliases do
    [
      "docs.show": ["docs", &open("doc/index.html", &1)],
      test: "espec --cover",
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:espec, "~> 1.9", only: :test},
      {:elixir_cmake, "~> 0.8"},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:muontrap, "~> 1.5"},
    ]
  end

  defp description do
    """
    Software TPM emulator
    """
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/redwirelabs/swtpm_ex"},
      maintainers: ["Abelino Romo"],
      files: [
        "CMakeLists.txt",
        "LICENSE",
        "README.md",
        "lib",
        "mix.exs",
      ],
    ]
  end

  defp plt_file_path do
    [Mix.Project.build_path(), "plt", "dialyxir.plt"]
    |> Path.join()
    |> Path.expand()
  end

  # Open a file with the default application for its type.
  defp open(file, _args) do
    open_command =
      System.find_executable("xdg-open") # Linux
      || System.find_executable("open")  # Mac
      || raise "Could not find executable 'open' or 'xdg-open'"

    System.cmd(open_command, [file])
  end
end
