import unittest
import patch
import line_comment

suite "line comment tests":
  test "select only applicable line comments":
    let patch = open("tests/fixtures/patch.patch")
    let changedLines = changedLinesInPatch(patch)
    let lineComments: seq[LineComment] = @[(14, "hello world"), (17, "sup"), (54, "2nd hello world")]
    let expected: seq[LineComment] = @[(14, "hello world"), (54, "2nd hello world")]
    let applicable = applicableLineComments(lineComments, changedLines)
    check(applicable == expected)
