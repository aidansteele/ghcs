import patch
import sequtils
import json
import math
import myutils

type LineComment* = tuple[path: string, lineNumber: int, comment: string]
type PatchComment* = tuple[path: string, position: int, comment: string]

proc patchComments*(comments: seq[LineComment], changedLines: seq[ChangedLine]): seq[PatchComment] =
  result = @[]
  
  for lc in comments:
    # TODO: hacking around my lack of knowledge
    let clx = filterIt(changedLines, it.lineNumber == lc.lineNumber and it.path == lc.path)
    if len(clx) > 0:
      let pc: PatchComment = (lc.path, clx[0].position, lc.comment)
      add(result, pc)

converter toLineComment*(node: JsonNode): LineComment =
  let ln = cast[int](getNum(node["line"]))
  result = (path: getStr(node["path"]), lineNumber: ln, comment: getStr(node["body"]))

converter toPatchComment*(node: JsonNode): PatchComment =
  let ln = cast[int](getNum(node["position"])) # TODO: or should it be original position?
  result = (path: getStr(node["path"]), position: ln, comment: getStr(node["body"]))

converter toJson*(lc: LineComment): JsonNode =
  result = %*{ "path": lc.path, "line": lc.lineNumber, "body": lc.comment }

converter toJson*(pc: PatchComment): JsonNode =
  result = %*{ "path": pc.path, "position": pc.position, "body": pc.comment }

when defined(testing):
  import unittest

  suite "line comment tests":
    test "select only applicable line comments":
      let patch = open("tests/fixtures/patch.patch")
      let changedLines = changedLinesInPatch(patch)
      let lineComments: seq[LineComment] = @[("", 14, "hello world"), ("", 17, "sup"), ("", 54, "2nd hello world")]
      let expected: seq[LineComment] = @[("", 14, "hello world"), ("", 54, "2nd hello world")]
      let applicable = applicableLineComments(lineComments, changedLines)
      check(applicable == expected)
