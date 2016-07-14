import diff
import sequtils
import json
import math
import myutils

type LineComment* = tuple[path: string, lineNumber: int, comment: string]
type PatchComment* = tuple[path: string, position: int, comment: string]

proc diffComments*(comments: seq[LineComment], changedLines: seq[ChangedLine]): seq[PatchComment] =
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
  import streams

  suite "line comment tests":
    test "select only applicable line comments":
      let diff = newFileStream("tests/fixtures/diff.diff")
      let changedLines = changedLinesInDiff(diff)
      let lineComments: seq[LineComment] = @[
        ("fastlane/lib/fastlane/actions/s3.rb", 13, "hello world"), 
        ("some/unchanged/file/in/pr", 17, "sup"), 
        ("fastlane/spec/actions_specs/s3_spec.rb", 54, "another message"),
      ]
      let expected: seq[PatchComment] = @[
        ("fastlane/lib/fastlane/actions/s3.rb", 4, "hello world"), 
        ("fastlane/spec/actions_specs/s3_spec.rb", 6, "another message"),
      ]
      let applicable = diffComments(lineComments, changedLines)
      check(applicable == expected)
