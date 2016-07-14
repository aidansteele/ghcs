import json
import uri
import http

type
  GithubApi* = ref object
    baseUri*: Uri
    token*: string

proc request*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil): JsonNode =
  let bodyStr = if isNil(body): "" else: $body
  let uri = combine(api.baseUri, parseUri(url))
  result = parseJson(rawRequest(uri, httpMethod, bodyStr).body)
  
