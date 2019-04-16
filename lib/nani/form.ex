defmodule Nani.Form do
  @default_headers [
    {"Accept", "*/*"},
    {"Content-Type", "application/x-www-form-urlencoded"}
  ]

  # response may have "application/json" content type
  @type result_t :: {:ok, String.t() | list | map} | {:error, String.t()}

  # http://blog.tap349.com/elixir/2017/08/17/elixir-httpoison/#submit-form-data
  # https://elixirforum.com/t/help-with-httpoison-post/11315
  #
  # POST params must have atom keys since they are converted to keyword list
  @spec post(String.t(), map, %{optional(atom) => any}, keyword) :: result_t()
  def post(url, query_params, post_params, opts \\ []) do
    Nani.Base.post(url, query_params, post_params, form_opts(opts))
  end

  defp form_opts(opts) do
    headers = Keyword.get(opts, :headers, [])
    put_in(opts[:headers], @default_headers ++ headers)
  end
end
