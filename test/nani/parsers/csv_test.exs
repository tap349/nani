defmodule Nani.Parsers.CSVTest do
  use ExUnit.Case, async: true
  alias Nani.Parsers.CSV

  test "parses CSV with headers and without rows" do
    csv = """
    Impressions,Clicks,Cost\
    """

    assert CSV.parse!(csv) == []
  end

  test "parses CSV with headers and 1 row" do
    csv = """
    Impressions,Clicks,Cost
    1,2,3.3\
    """

    assert CSV.parse!(csv) == [
             %{
               "Impressions" => "1",
               "Clicks" => "2",
               "Cost" => "3.3"
             }
           ]
  end

  test "parses CSV with headers and 2 rows" do
    csv = """
    Impressions,Clicks,Cost
    1,2,3.3
    10,20,30.3\
    """

    assert CSV.parse!(csv) == [
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
