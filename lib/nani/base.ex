defmodule Nani.Base do
  alias HTTPoison.{Response, Error}
  require Logger

  @type result_t :: {:ok, String.t()} | {:error, String.t()}
  @type raw_result_t :: {:ok, Response.t()} | {:error, Error.t()}

  @default_headers []
  # timeout is 8000ms by default
  # recv_timeout is 5000ms by default
  @default_options [timeout: 32_000, recv_timeout: 60_000]

  @spec get(String.t(), map, keyword) :: result_t
  def get(url, query_params, opts \\ []) do
    url
    |> url_with_query(query_params)
    |> URI.encode()
    |> HTTPoison.get(headers(opts), options(opts))
    |> log_response()
    |> handle_response()
  end

  @spec get_raw(String.t(), map, keyword) :: raw_result_t
  def get_raw(url, query_params, opts \\ []) do
    url
    |> url_with_query(query_params)
    |> URI.encode()
    |> HTTPoison.get(headers(opts), options(opts))
  end

  @spec post(String.t(), map, map, keyword) :: result_t
  def post(url, query_params, post_params, opts \\ []) do
    post_params = Jason.encode!(post_params)

    url
    |> url_with_query(query_params)
    |> URI.encode()
    |> HTTPoison.post(post_params, headers(opts), options(opts))
    |> log_response()
    |> handle_response()
  end

  defp url_with_query(url, query_params) when query_params == %{} do
    url
  end

  # URI.encode_query/1 converts map into a query
  # string and percent-encodes both keys and values
  #
  # URI.decode/1 then percent-decodes this string
  defp url_with_query(url, query_params) do
    query_string =
      query_params
      |> URI.encode_query()
      |> URI.decode()

    "#{url}?#{query_string}"
  end

  defp headers(opts) do
    headers = Keyword.get(opts, :headers, [])
    @default_headers ++ headers
  end

  defp options(opts) do
    options = Keyword.get(opts, :options, [])
    Keyword.merge(@default_options, options)
  end

  # -----------------------------------------------------------------
  # log_response
  # -----------------------------------------------------------------

  defp log_response({:ok, %Response{status_code: status_code}} = response)
       when status_code in [200, 201] do
    Logger.debug("API RESPONSE:\n" <> inspect(response))
    response
  end

  defp log_response({:ok, _} = response) do
    Logger.error("API RESPONSE:\n" <> inspect(response))
    response
  end

  defp log_response({:error, _} = response) do
    Logger.error("API RESPONSE:\n" <> inspect(response))
    response
  end

  # -----------------------------------------------------------------
  # handle response
  #
  # gzipped body should be decoded transparently by HTTPoison if
  # "Content-Encoding: gzip" header is set but it can be missing
  # so check if URL leads to gzipped file manually
  # -----------------------------------------------------------------

  defp handle_response({:ok, %Response{status_code: status_code} = response})
       when status_code in [200, 201] do
    %{body: body, request: %{url: url}} = response

    case String.ends_with?(url, "gz") do
      true -> {:ok, :zlib.gunzip(body)}
      false -> {:ok, body}
    end
  end

  defp handle_response({:ok, %Response{body: body} = response})
       when body in ["", " "] do
    {:error, "#{response.status_code}"}
  end

  defp handle_response({:ok, %Response{} = response}) do
    {:error, "#{response.status_code}: #{response.body}"}
  end

  # reason can be atom or tuple - convert it to string
  defp handle_response({:error, %Error{reason: reason}}) do
    {:error, inspect(reason)}
  end
end
