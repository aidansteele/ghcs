import uri
import curl
import streams
import httpcore
import nre
import options
import json
import os
  
type HttpResponse* = object
  body*: string
  status*: int
  headers*: HttpHeaders

proc logItMaybe(httpMethod: string, uri: Uri, body: string, response: HttpResponse) =
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

discard global_init(GLOBAL_ALL)
var handle {.threadvar.}: PCurl

proc curlWriteCb(data: cstring, size: int, nmemb: int, context: Stream): int {.exportc.} =
  let actualSize = size * nmemb
  writeData(context, data, actualSize) # data is not null-terminated
  result = actualSize

let headerRegex = re"(*CRLF)^\s*([^:]+)\s*:\s*(.+)$"
proc parseHeaderLine(line: string): Option[tuple[name: string, value: string]] =
  let matches = match(line, headerRegex)
  if isSome(matches):
    let caps = get(matches).captures
    let name = caps[0]
    let value = caps[1]
    result = some((name, value))

proc curlHeaderCb(data: cstring, size: int, nmemb: int, context: HttpHeaders): int {.exportc.} =
  let actualSize = size * nmemb
  var headerLine = newString(actualSize)
  copyMem(addr(headerLine[0]), data, actualSize)
  let header = parseHeaderLine(headerLine)
  if isSome(header):
    let name = get(header).name
    let value = get(header).value
    add(context, name, value)
  result = actualSize

proc rawRequest*(uri: Uri, httpMethod: string, body = "", headers: HttpHeaders = nil): HttpResponse =
  var slist: Pslist

  if headers == nil or hasKey(headers, "User-Agent") == false:
    slist = slist_append(slist, "User-Agent: ghcs/1.0")

  if headers != nil:
    for name, value in headers:
      let line = name & ": " & value
      slist = slist_append(slist, line)  

  let stream = newStringStream()

  if isNil(handle):
    handle = easy_init()
  else:
    easy_reset(handle)

  let responseHeaders = newHttpHeaders()
    
  discard easy_setopt(handle, OPT_URL, $uri)
  discard easy_setopt(handle, OPT_WRITEFUNCTION, curlWriteCb)
  discard easy_setopt(handle, OPT_WRITEDATA, stream)
  discard easy_setopt(handle, OPT_HTTPHEADER, slist)
  discard easy_setopt(handle, OPT_HEADERFUNCTION, curlHeaderCb)
  discard easy_setopt(handle, OPT_HEADERDATA, responseHeaders)
  discard easy_setopt(handle, OPT_ENCODING, "") # empty string tells curl to use defaults
  
  if len(body) > 0:
    discard easy_setopt(handle, OPT_POSTFIELDS, body)
    discard easy_setopt(handle, OPT_POSTFIELDSIZE, len(body))
    discard easy_setopt(handle, OPT_CUSTOMREQUEST, httpMethod)

  let res = easy_perform(handle)
  if res != E_OK:
    echo("curl failed: " & $easy_strerror(res))

  slist_free_all(slist)

  var statusCode: int = 0
  discard easy_getinfo(handle, INFO_RESPONSE_CODE, addr statusCode)
  
  setPosition(stream, 0)
  let respBody = readAll(stream)
  result = HttpResponse(body: respBody, status: statusCode, headers: responseHeaders)
  logItMaybe(httpMethod, uri, body, result)    
