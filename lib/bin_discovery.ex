defmodule BinDiscovery do
  @moduledoc false

  @source_bins "/tmp/source_bins.txt"

  def build_index do
    assert_source_bins!()

    outfile =
      File.stream!("./index.txt")

    File.stream!(@source_bins)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&match?("", &1))
    |> Stream.map(&man_for/1)
    |> Stream.reject(&match?({_, nil}, &1))
    |> Stream.map(&man_description/1)
    |> Stream.reject(&match?(nil, &1))
    |> Enum.into(outfile)
  end



  ############################################################
  # Private Helpers
  ############################################################

  @spec assert_source_bins! :: :ok | no_return
  defp assert_source_bins! do
    unless File.exists?(@source_bins) do
      raise("Cannot find the \"source_bins.txt\" file at #{inspect(@source_bins)}. Run the \"./scripts/bin_discovery.sh\" script.")
    end
  end

  @spec man_for(binary) :: {binary, binary}
  defp man_for(bin) do
    {manpage, _} =
      System.cmd("man", [bin], stderr_to_stdout: true)

    case manpage do
      "No manual entry for this\n"    -> {bin, nil}
      manpage when is_binary(manpage) -> {bin, manpage}
    end
  end

  @spec man_description({binary, binary}) :: String.t
  defp man_description({bin, manpage}) do
    case Regex.run(~r/NAME\n+\s*(.+)/, manpage, capture: :all_but_first) do
      nil      -> nil
      [result] -> "#{bin} - #{maybe_strip_name_and_version(result)}"
    end
  end

  @spec maybe_strip_name_and_version(String.t) :: String.t
  defp maybe_strip_name_and_version(description) do
    description =
      Regex.replace(~r/(^[^-]+- )/, description, "")

    description =
      Regex.replace(~r/,?\sv\d+\..+$/, description, "")

    description =
      description
      |> String.trim()
      |> String.capitalize()

    description <> "\n"
  end
end
