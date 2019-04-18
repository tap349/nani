## v0.2.2

- fix bugs introduced in v0.2.0 (incorrect processing of errors)

## v0.2.1

- when using `Nani.Form` it's necessary to pass POST params as a
  keyword list

## v0.2.0

breaking changes:

- `Content-Type` request header is used to process POST params
  (say, to encode JSON params)
- `Content-Type` response header is used to process response body
  (say, to parse response body)
- add `Nani.Form` helper module to submit form data
- `Nani.JSON` and `Nani.Form` modules just add correct headers -
  all the processing takes place in `Nani.Base` now
- log prefix is changed from `API RESPONSE` `HTTP RESPONSE`

## v0.1.4

- add Nani.Result.wrap/1

## v0.1.3

- add add Nani.Base.post_raw/4

## v0.1.0

- initial release
