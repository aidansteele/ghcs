import httpclient
import base64
import json
import uri

type
  GithubApi* = ref object of RootObj
    baseUri*: Uri
    token*: string

proc authHeader(api: GithubApi): string =
  let auth = api.token & ":x-oauth-basic"
  let authEncoded = encode(auth, lineLen=1024)
  result = "Authorization: Basic " & authEncoded & "\c\L"

proc request*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil): JsonNode =
  let bodyStr = if isNil(body): "" else: $body
  let lengthHeader = "Content-Length: " & $len(bodyStr) & "\c\L"
  let extraHeaders = authHeader(api) & lengthHeader
  let uri = combine(api.baseUri, parseUri(url))
  let prefixedMethod = "http" & httpMethod
  let resp = request($uri, prefixedMethod, extraHeaders = extraHeaders, body = bodyStr)
  result = parseJson(resp.body)
