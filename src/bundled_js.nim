import macros, strutils, tables, sequtils

macro bundleUpJavascript(): expr =
  let s = staticExec "find js -name '*.js'"
  let files = s.splitLines
  result = newStmtList()
  # TODO: something far less inefficent than string concat. stdlib rope is better
  var r = ""
  r = r & """const bundledJs = {"_": nil"""
  for file in files:
     let src = ", \"" & file & "\": staticRead(\"" & file & "\")"
     r = r & src
  r = r & "}.toTable"
  result.add(parseStmt(r))

bundleUpJavascript()

proc getBundledFilenames*(): seq[string] =
  toSeq(keys(bundledJs))

proc sourceForBundledFilename*(name: string): string =
  bundledJs[name]
