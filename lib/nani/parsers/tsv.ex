defmodule Nani.Parsers.TSV do
  NimbleCSV.define(Default, separator: "\t")

  def parse!(tsv, opts \\ []) do
    Nani.Parsers.CSV.parse!(tsv, Default, opts)
  end
end
