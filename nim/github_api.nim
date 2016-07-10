import httpclient
import base64
import json
import uri
import os

type
  GithubApi* = ref object
    baseUri*: Uri
    token*: string

proc authHeader(api: GithubApi): string =
  let auth = api.token & ":x-oauth-basic"
  let authEncoded = encode(auth, lineLen=1024)
  result = "Authorization: Basic " & authEncoded & "\c\L"

proc logItMaybe(httpMethod: string, uri: Uri, body: string, response: Response) =
  let outLocation = getEnv("HTTP_LOGGING")
  if len(outLocation) > 0:
    let fd = open(outLocation, fmAppend)
    let node = %*{ 
      "method": httpMethod, 
      "uri": $uri, 
      "requestBody": body,
      "responseBody": response.body,
      "responseCode": response.status
    }
    writeln(fd, $node)
    close(fd)

proc rawRequest*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil, headers = ""): string =
  let bodyStr = if isNil(body): "" else: $body
  let lengthHeader = "Content-Length: " & $len(bodyStr) & "\c\L"
  let extraHeaders = authHeader(api) & headers & lengthHeader
  let uri = combine(api.baseUri, parseUri(url))
  let prefixedMethod = "http" & httpMethod
  
  var proxy: Proxy
  if existsEnv("http_proxy"):
    proxy = newProxy(getEnv("http_proxy"))
  
  let resp = request($uri, prefixedMethod, extraHeaders = extraHeaders, body = bodyStr, proxy = proxy)
  result = resp.body

  logItMaybe(httpMethod, uri, bodyStr, resp)

proc request*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil): JsonNode =
  result = parseJson(rawRequest(api, httpMethod, url, body))
  
