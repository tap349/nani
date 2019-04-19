defmodule Nani.Parsers.TSVTest do
  use ExUnit.Case, async: true
  alias Nani.Parsers.TSV

  test "parses TSV with headers and without rows" do
    tsv = """
    Impressions	Clicks	Cost\
    """

    assert TSV.parse!(tsv) == []
  end

  test "parses TSV with headers and 1 row" do
    tsv = """
    Impressions	Clicks	Cost
    1	2	3.3\
    """

    assert TSV.parse!(tsv) == [
             %{
               "Impressions" => "1",
               "Clicks" => "2",
               "Cost" => "3.3"
             }
           ]
  end

  test "parses TSV with headers and 2 rows" do
    tsv = """
    Impressions	Clicks	Cost
    1	2	3.3
    10	20	30.3\
    """

    assert TSV.parse!(tsv) == [
             %{
               "Impressions" => "1",
               "Clicks" => "2",
               "Cost" => "3.3"
             },
             %{
               "Impressions" => "10",
               "Clicks" => "20",
               "Cost" => "30.3"
             }
           ]
  end
end
