defmodule Nani.Parsers.TSV do
  NimbleCSV.define(Default, separator: "\t")

  def parse!(tsv) do
    Nani.Parsers.CSV.parse!(tsv, Default)
  end
end
