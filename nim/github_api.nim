import json
import uri
import http
import base64
import httpcore

type
  GithubApi* = ref object
    baseUri*: Uri
    token*: string

proc addAuthHeader*(api: GithubApi, headers: HttpHeaders) =
  headers["Authorization"] = "Basic " & encode(api.token & ":x-oauth-basic")

proc request*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil): JsonNode =
  let bodyStr = if isNil(body): "" else: $body
  let uri = combine(api.baseUri, parseUri(url))
  let headers = newHttpHeaders()
  addAuthHeader(api, headers)
  result = parseJson(rawRequest(uri, httpMethod, bodyStr, headers).body)
  
