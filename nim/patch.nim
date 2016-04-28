import nre
import options
import strutils

let rangeInfoLine = re"^@@ .+\+(\d+),"
let modifiedLine = re"^\+(?!\+|\+)"
let notRemovedLine = re"^[^-]"

type ChangedLine* = tuple[lineNumber: int, position: int]

proc changedLinesInPatch*(f: File): seq[ChangedLine] =
  var lineNumber = 0
  var position = 0
  result = newSeq[ChangedLine]()

  for lineSansNL in lines(f):
    let line = lineSansNL & "\n"
    var matches = match(line, rangeInfoLine)

    if isSome(matches):
      lineNumber = parseInt(get(matches).captures[0])
    elif isSome(match(line, modifiedLine)):
      let cl: ChangedLine = (lineNumber, position)
      add(result, cl)
      lineNumber += 1
    elif isSome(match(line, notRemovedLine)):
      lineNumber += 1

    position += 1

when defined(testing):
  import unittest

  suite "patch-file parsing tests":
    test "patch-file modified line numbers":
      let patch = open("tests/fixtures/patch.patch")
      let lineNumbers = changedLinesInPatch(patch)
      let expected: seq[ChangedLine] = @[(14, 5), (22, 13), (54, 37)]
      check(lineNumbers == expected)
