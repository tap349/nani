# https://stackoverflow.com/a/37039584/3632318
defmodule Nani.Parsers.CSV do
  def parse!(csv) do
    parse!(csv, NimbleCSV.RFC4180)
  end

  def parse!(string, parser) do
    string
    |> parser.parse_string(skip_headers: false)
    |> to_maps()
  end

  defp to_maps(rows) do
    rows
    |> Stream.transform(nil, &process_row/2)
    |> Enum.to_list()
  end

  defp process_row(headers, nil) do
    {[], headers}
  end

  defp process_row(row, headers) do
    map =
      headers
      |> Enum.zip(row)
      |> Enum.into(%{})

    {[map], headers}
  end
end
