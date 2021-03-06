## v0.5.0

- extract CSV and TSV parsers into separate package - `yuki`.

## v0.4.0

- remove automatic parsing of CSV and TSV - now they can be parsed manually
  with `Nani.Parsers.CSV` and `Nani.Parsers.TSV` modules
- add `skip_first_lines` and `skip_last_lines` options to `parse!` functions
  of `Nani.Parsers.CSV` and `Nani.Parsers.TSV` modules

## v0.3.2

- fix bug that can be encountered when status code is successful but not 200

## v0.3.1

- parse response body as JSON when content type is `text/javascript` -
  it's used in Facebook API responses

## v0.3.0

- parse CSV and TSV response bodies to list of maps automatically (it's
  assumed headers are always present)

## v0.2.2

- fix bugs introduced in v0.2.0 (incorrect processing of errors)

## v0.2.1

- when using `Nani.Form` it's necessary to pass POST params as a keyword
  list now

## v0.2.0

breaking changes:

- `Content-Type` request header is used to process POST params (say, to
  encode JSON params)
- `Content-Type` response header is used to process response body (say,
  to parse response body)
- add `Nani.Form` helper module to submit form data
- `Nani.JSON` and `Nani.Form` modules just add correct headers - all the
  processing takes place in `Nani.Base` now
- log prefix is changed from `API RESPONSE` `HTTP RESPONSE`

## v0.1.4

- add `Nani.Result.wrap/1`

## v0.1.3

- add add `Nani.Base.post_raw/4`

## v0.1.0

- initial release
