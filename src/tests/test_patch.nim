import unittest
import patch

suite "patch-file parsing tests":
  test "patch-file modified line numbers":
    let patch = open("tests/fixtures/patch.patch")
    let lineNumbers = changedLinesInPatch(patch)
    let expected: seq[ChangedLine] = @[(14, 5), (22, 13), (54, 37)]
    check(lineNumbers == expected)
