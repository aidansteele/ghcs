import patch
import sequtils
import json
import math

type LineComment* = tuple[path: string, lineNumber: int, comment: string]

proc applicableLineComments*(comments: seq[LineComment], changedLines: seq[ChangedLine]): seq[LineComment] =
  result = filter(comments) do (lc: LineComment) -> bool:
    any(changedLines) do (cl: ChangedLine) -> bool:
      cl.lineNumber == lc.lineNumber

converter toLineComment*(node: JsonNode): LineComment =
  let ln = cast[int](getNum(node["line"]))
  result = (path: getStr(node["path"]), lineNumber: ln, comment: getStr(node["body"]))

converter toJson*(lc: LineComment): JsonNode =
  result = %*{ "path": lc.path, "line": lc.lineNumber, "body": lc.comment }

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
