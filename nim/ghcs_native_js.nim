import json
import osproc
import httpclient
import strutils
import strtabs
import streams
import sequtils
import os
import http
import uri

proc ghcsReadFile*(json: JsonNode): JsonNode {.procvar.} =
  let path = json["path"].str
  let contents = readFile(path)
  result = %*{ "contents": contents }

proc ghcsWriteFile*(json: JsonNode): JsonNode {.procvar.} =
  let path = json["path"].str
  let data = json["data"].str
  writeFile(path, data)
  result = %*{ "success": true }

proc ghcsStdin*(json: JsonNode): JsonNode {.procvar.} =
  let str = readAll(stdin)
  result = %* { "stdin": str }

proc ghcsStdout*(json: JsonNode): JsonNode {.procvar.} =
  let str = json["stdout"].str
  echo(str)
  result = %*{ "noop": true }

proc ghcsShell*(json: JsonNode): JsonNode {.procvar.} =
  let cmd = json["command"].str
  let inputData = json["stdin"].str

  var p = startProcess(cmd, options={poEvalCommand})
  var inp = inputStream(p)
  if len(inputData) > 0:
    write(inp, inputData)
    close(inp)

  let outp = outputStream(p)
  let outputData = readAll(outp)

  let exitCode = peekExitCode(p)
  assert(exitCode != -1)

  result = %*{ "stdout": outputData, "exitCode": exitCode }

proc ghcsArgv*(json: JsonNode): JsonNode {.procvar.} =
  let argv = map(commandLineParams(), proc(x: TaintedString): JsonNode = newJString($x))
  result = %*{ "argv": argv }

proc ghcsHttp*(json: JsonNode): JsonNode {.procvar.} =
  let url = json["url"].str
  let requestBody = json["body"].str
  let httpMethod = json["method"].str

  let uri = parseUri(url)
  let requestHeaders = newHttpHeaders()

  for key, val in json["headers"]:
    add(requestHeaders, key, val.str)

  let resp = rawRequest(uri, httpMethod, requestBody, requestHeaders)

  result = %*{ "body": resp.body, "statusCode": resp.status, "headers": newJObject() }
  for key, val in resp.headers:
    add(result["headers"], key, %val)
