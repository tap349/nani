defmodule Nani.Parsers.TSVTest do
  use ExUnit.Case, async: true
  alias Nani.Parsers.TSV

  describe "parse!/2" do
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

    test "skips the first 2 lines" do
      csv = """
      foo	bar	baz
      			
      Impressions	Clicks	Cost
      1	2	3.3\
      """

      assert TSV.parse!(csv, skip_first_lines: 2) == [
               %{
                 "Impressions" => "1",
                 "Clicks" => "2",
                 "Cost" => "3.3"
               }
             ]
    end

    test "skips the last 2 lines" do
      csv = """
      Impressions	Clicks	Cost
      1	2	3.3
      foo	bar	baz
      			\
      """

      assert TSV.parse!(csv, skip_last_lines: 2) == [
               %{
                 "Impressions" => "1",
                 "Clicks" => "2",
                 "Cost" => "3.3"
               }
             ]
    end
  end
end
