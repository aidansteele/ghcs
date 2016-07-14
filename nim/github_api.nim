import json
import uri
import curl
import streams
import httpcore

type
  GithubApi* = ref object
    baseUri*: Uri
    token*: string

# proc logItMaybe(httpMethod: string, uri: Uri, body: string, response: Response) =
#   let outLocation = getEnv("HTTP_LOGGING")
#   if len(outLocation) > 0:
#     let fd = open(outLocation, fmAppend)
#     let node = %*{ 
#       "method": httpMethod, 
#       "uri": $uri, 
#       "requestBody": body,
#       "responseBody": response.body,
#       "responseCode": response.status
#     }
#     writeln(fd, $node)
#     close(fd)

discard global_init(GLOBAL_ALL)
let handle = easy_init()

proc curlWriteCb(data: cstring, size: int, nmemb: int, context: Stream): int {.exportc.} =
  let actualSize = size * nmemb
  writeData(context, data, actualSize) # data is not null-terminated
  result = actualSize

proc rawRequest*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil, headers: HttpHeaders = nil): string =
  let bodyStr = if isNil(body): "" else: $body
  let uri = combine(api.baseUri, parseUri(url))

  var slist: Pslist

  if headers == nil or hasKey(headers, "User-Agent") == false:
    slist = slist_append(slist, "User-Agent: ghcs/1.0")

  if headers != nil:
    for name, value in headers:
      let line = name & ": " & value
      slist = slist_append(slist, line)  

  let stream = newStringStream()

  easy_reset(handle)
  discard easy_setopt(handle, OPT_URL, $uri)
  discard easy_setopt(handle, OPT_WRITEFUNCTION, curlWriteCb)
  discard easy_setopt(handle, OPT_WRITEDATA, stream)
  discard easy_setopt(handle, OPT_HTTPHEADER, slist)
  discard easy_setopt(handle, OPT_ENCODING, "") # empty string tells curl to use defaults
  discard easy_setopt(handle, OPT_USERPWD, api.token & ":x-oauth-basic")
  
  if len(bodyStr) > 0:
    discard easy_setopt(handle, OPT_POSTFIELDS, bodyStr)
    discard easy_setopt(handle, OPT_POSTFIELDSIZE, len(bodyStr))
    discard easy_setopt(handle, OPT_CUSTOMREQUEST, httpMethod)

  let res = easy_perform(handle)
  if res != E_OK:
    echo("curl failed: " & $easy_strerror(res))

  slist_free_all(slist)
  
  setPosition(stream, 0)
  result = readAll(stream)
  # logItMaybe(httpMethod, uri, bodyStr, resp)    

proc request*(api: GithubApi, httpMethod: string, url: string, body: JsonNode = nil): JsonNode =
  result = parseJson(rawRequest(api, httpMethod, url, body))
  
