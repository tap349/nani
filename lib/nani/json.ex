defmodule Nani.JSON do
  @default_headers [
    {"Accept", "application/json; charset=utf-8"},
    {"Content-Type", "application/json; charset=utf-8"}
  ]

  @type result_t :: {:ok, list | map} | {:error, String.t()}

  @spec get(String.t(), map, keyword) :: result_t()
  def get(url, query_params, opts \\ []) do
    Nani.Base.get(url, query_params, json_opts(opts))
  end

  @spec post(String.t(), map, map, keyword) :: result_t()
  def post(url, query_params, post_params, opts \\ []) do
    Nani.Base.post(url, query_params, post_params, json_opts(opts))
  end

  defp json_opts(opts) do
    headers = Keyword.get(opts, :headers, [])
    put_in(opts[:headers], @default_headers ++ headers)
  end
end
