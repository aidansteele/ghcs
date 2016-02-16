import json
import osproc
import httpclient
import strutils
import strtabs
import sequtils
import os

proc ghcsReadFile*(json: JsonNode): JsonNode {.procvar.} =
  let path = json["path"].str
  let contents = readFile(path)
  result = %*{ "contents": contents }

proc ghcsStdin*(json: JsonNode): JsonNode {.procvar.} =
  let str = readAll(stdin)
  result = %* { "stdin": str }

proc ghcsStdout*(json: JsonNode): JsonNode {.procvar.} =
  let str = json["stdout"].str
  echo(str)
  result = %*{ "noop": true }

proc ghcsShell*(json: JsonNode): JsonNode {.procvar.} =
  let cmd = json["command"].str
  let (outp, exitCode) = execCmdEx(cmd)
  result = %*{ "output": outp, "exitCode": exitCode }

proc ghcsArgv*(json: JsonNode): JsonNode {.procvar.} =
  let argv = map(commandLineParams(), proc(x: TaintedString): JsonNode = newJString($x))
  result = %*{ "argv": argv }

proc ghcsHttp*(json: JsonNode): JsonNode {.procvar.} =
  let url = json["url"].str
  let requestBody = json["body"].str
  let httpMethod = json["method"].str
  let requestHeaders = json["headers"]

  var headerString = "Content-Length: $1\c\L" % [$len(requestBody)]
  for key, val in requestHeaders:
    # TODO: unescape json string $val
    headerString = headerString & "$1: $2\c\L" % [key, $val]

  let prefixedMethod = "http" & httpMethod
  let resp = request(url, prefixedMethod, extraHeaders = headerString, body = requestBody)
  let responseHeaders = resp.headers

  let respHeaderNodes = newJObject()
  for key, val in resp.headers:
    respHeaderNodes[key] = newJString(val)

  result = %*{ "body": resp.body, "statusCode": resp.status }
  result["headers"] = respHeaderNodes
