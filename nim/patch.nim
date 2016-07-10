import nre
import options
import strutils
import streams

let rangeInfoLine = re"^@@ .+\+(\d+),"
let modifiedLine = re"^\+(?!\+|\+)"
let notRemovedLine = re"^ "
let filenameLine = re"^\+\+\+ b/(.+)"

type ChangedLine* = tuple[path: string, lineNumber: int, position: int]

proc changedLinesInPatch*(f: Stream): seq[ChangedLine] =
  var lineNumber = 0
  var position = 0
  var path = ""
  result = newSeq[ChangedLine]()

  var lineSansNL = ""
  while readLine(f, lineSansNL):
    let line = lineSansNL & "\n"

    var matches = match(line, rangeInfoLine)
    if isSome(matches):
      lineNumber = parseInt(get(matches).captures[0])

    if isSome(match(line, modifiedLine)):
      let cl: ChangedLine = (path, lineNumber, position)
      add(result, cl)
      lineNumber += 1
    
    if isSome(match(line, notRemovedLine)):
      lineNumber += 1

    position += 1

    matches = match(line, filenameLine)
    if isSome(matches):
      path = get(matches).captures[0]
      position = 0

when defined(testing):
  import unittest

  suite "patch-file parsing tests":
    test "patch-file modified line numbers":
      let patch = newFileStream("tests/fixtures/diff.diff")
      let lineNumbers = changedLinesInPatch(patch)
      let expected: seq[ChangedLine] = @[("", 14, 5), ("", 22, 13), ("", 54, 37)]
      check(lineNumbers == expected)
