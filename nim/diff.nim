import nre
import options
import strutils
import streams

let rangeInfoLine = re"^@@ .+\+(\d+),"
let modifiedLine = re"^\+(?!\+|\+)"
let notRemovedLine = re"^ "
let filenameLine = re"^\+\+\+ b/(.+)"

type ChangedLine* = tuple[path: string, lineNumber: int, position: int]

proc changedLinesInDiff*(f: Stream): seq[ChangedLine] =
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

  suite "diff-file parsing tests":
    test "diff-file modified line numbers":
      let diff = newFileStream("tests/fixtures/diff.diff")
      let lineNumbers = changedLinesInDiff(diff)
      let expected: seq[ChangedLine] = @[
        ("fastlane/lib/assets/s3_html_template.erb", 53, 5),
        ("fastlane/lib/fastlane/actions/s3.rb", 13, 4),
        ("fastlane/lib/fastlane/actions/s3.rb", 144, 12),
        ("fastlane/lib/fastlane/actions/s3.rb", 145, 13),
        ("fastlane/lib/fastlane/actions/s3.rb", 146, 14),
        ("fastlane/spec/actions_specs/s3_spec.rb", 52, 4),
        ("fastlane/spec/actions_specs/s3_spec.rb", 53, 5),
        ("fastlane/spec/actions_specs/s3_spec.rb", 54, 6),
        ("fastlane/spec/actions_specs/s3_spec.rb", 56, 12)
      ]
      check(lineNumbers == expected)
