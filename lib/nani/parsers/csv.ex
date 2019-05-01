# https://stackoverflow.com/a/37039584/3632318
defmodule Nani.Parsers.CSV do
  @default_options [skip_first_lines: 0, skip_last_lines: 0]

  def parse!(csv, opts \\ []) do
    parse!(csv, NimbleCSV.RFC4180, opts)
  end

  def parse!(string, parser, opts) do
    options = Keyword.merge(@default_options, opts)

    string
    |> parser.parse_string(skip_headers: false)
    |> Enum.drop(options[:skip_first_lines])
    |> Enum.drop(-options[:skip_last_lines])
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
