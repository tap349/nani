defmodule Nani.Base do
  use Hayase
  alias HTTPoison.{Response, Error}
  require Logger

  @success_status_codes [200, 201]

  @default_headers []
  # timeout is 8000ms by default
  # recv_timeout is 5000ms by default
  @default_options [timeout: 32_000, recv_timeout: 60_000]

  @type result_t :: {:ok, String.t() | list | map} | {:error, String.t()}
  @type raw_result_t :: {:ok, Response.t()} | {:error, Error.t()}

  @spec get(String.t(), map, keyword) :: result_t
  def get(url, query_params, opts \\ []) do
    url
    |> get_raw(query_params, opts)
    |> process_response()
  end

  @spec post(String.t(), map, map | keyword, keyword) :: result_t
  def post(url, query_params, post_params, opts \\ []) do
    url
    |> post_raw(query_params, post_params, opts)
    |> process_response()
  end

  @spec get_raw(String.t(), map, keyword) :: raw_result_t
  def get_raw(url, query_params, opts \\ []) do
    headers = request_headers(opts)
    options = request_options(opts)

    url
    |> request_url_with_query(query_params)
    |> URI.encode()
    |> HTTPoison.get(headers, options)
    |> log_response()
  end

  @spec post_raw(String.t(), map, map | keyword, keyword) :: raw_result_t
  def post_raw(url, query_params, post_params, opts \\ []) do
    headers = request_headers(opts)
    options = request_options(opts)
    body = request_body(post_params, headers)

    url
    |> request_url_with_query(query_params)
    |> URI.encode()
    |> HTTPoison.post(body, headers, options)
    |> log_response()
  end

  # -----------------------------------------------------------------
  # request helpers
  # -----------------------------------------------------------------

  defp request_url_with_query(url, query_params) when query_params == %{} do
    url
  end

  # URI.encode_query/1 converts map into a query
  # string and percent-encodes both keys and values
  #
  # URI.decode/1 then percent-decodes this string
  defp request_url_with_query(url, query_params) do
    query_string =
      query_params
      |> URI.encode_query()
      |> URI.decode()

    "#{url}?#{query_string}"
  end

  defp request_body(post_params, headers) do
    content_type = Map.new(headers)["Content-Type"]

    case content_type do
      nil ->
        raise "Request Content-Type not set"

      "application/json" <> _ ->
        Jason.encode!(post_params)

      "application/x-www-form-urlencoded" <> _ ->
        if !Keyword.keyword?(post_params) do
          raise "POST params must be a keyword list"
        end

        {:form, post_params}

      _ ->
        raise "Request Content-Type not supported: #{content_type}"
    end
  end

  defp request_headers(opts) do
    headers = Keyword.get(opts, :headers, [])
    @default_headers ++ headers
  end

  defp request_options(opts) do
    options = Keyword.get(opts, :options, [])
    Keyword.merge(@default_options, options)
  end

  # -----------------------------------------------------------------
  # response helpers
  # -----------------------------------------------------------------

  defp log_response({:ok, %Response{status_code: status_code}} = result)
       when status_code in @success_status_codes do
    {_, response} = result
    Logger.debug("HTTP RESPONSE: #{inspect(response)}")
    result
  end

  defp log_response(result) do
    {_, response} = result
    Logger.error("HTTP RESPONSE: #{inspect(response)}")
    result
  end

  defp process_response(result) do
    result
    |> check_response_status()
    |> fmap(&gunzip_response_body/1)
    |> fmap(&parse_response_body/1)
    |> fmap(&extract_response_body/1)
  end

  defp check_response_status({:ok, %Response{status_code: status_code}} = result)
       when status_code in @success_status_codes do
    result
  end

  defp check_response_status({:ok, response}) do
    %{body: body, status_code: status_code} = response

    case String.trim(body) do
      "" -> {:error, "#{status_code}"}
      _ -> {:error, "#{status_code}: #{body}"}
    end
  end

  # error can be string, atom, tuple or HTTPoison.Error struct
  defp check_response_status({:error, error}) do
    {:error, inspect(error)}
  end

  # https://github.com/edgurgel/httpoison/issues/81
  #
  # gzipped body should be decoded transparently by HTTPoison if
  # "Content-Encoding: gzip" or "Content-Encoding: x-gzip" header
  # is set but this feature is not implemented yet and this header
  # may be missing so check if URL leads to gzipped file manually
  defp gunzip_response_body(%Response{status_code: 200} = response) do
    %{body: body, request: %{url: url}} = response

    case String.ends_with?(url, "gz") do
      true -> %{response | body: :zlib.gunzip(body)}
      false -> response
    end
  end

  defp parse_response_body(response) do
    %{body: body, headers: headers} = response

    content_type =
      headers
      |> Map.new()
      |> Map.fetch!("Content-Type")

    case content_type do
      "application/json" <> _ ->
        %{response | body: Jason.decode!(body)}

      _ ->
        response
    end
  end

  defp extract_response_body(%Response{body: body}), do: body
end
