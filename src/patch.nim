const pcre = staticExec("pkg-config --libs-only-L libpcre")
const pcrePath = pcre[2 .. high(pcre)]
{.link: pcrePath & "/libpcre.a".}

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
