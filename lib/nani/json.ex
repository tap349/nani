defmodule Nani.JSON do
  @default_headers [
    {"Accept", "application/json; charset=UTF-8"},
    {"Content-Type", "application/json"}
  ]

  @spec get(String.t(), map, keyword) :: Nani.Base.result_t()
  def get(url, query_params, opts \\ []) do
    opts = put_in(opts[:headers], headers(opts))

    url
    |> Nani.Base.get(query_params, opts)
    |> parse_response()
  end

  @spec post(String.t(), map, map, keyword) :: Nani.Base.result_t()
  def post(url, query_params, post_params, opts \\ []) do
    opts = put_in(opts[:headers], headers(opts))

    url
    |> Nani.Base.post(query_params, post_params, opts)
    |> parse_response()
  end

  defp headers(opts) do
    headers = Keyword.get(opts, :headers, [])
    @default_headers ++ headers
  end

  # -----------------------------------------------------------------
  # parse response
  # -----------------------------------------------------------------

  defp parse_response({:ok, body}), do: {:ok, Jason.decode!(body)}
  defp parse_response(response), do: response
end
