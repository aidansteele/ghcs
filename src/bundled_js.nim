import macros, strutils, tables, sequtils

macro bundleUpJavascript(): expr =
  let s = staticExec "(cd js && find . -name '*.js' -exec basename {} \\;)"
  let files = s.splitLines
  result = newStmtList()
  # TODO: something far less inefficent than string concat. stdlib rope is better
  var r = ""
  r = r & """const bundledJs = {"_": nil"""
  for file in files:
     let src = ", \"" & file & "\": staticRead(\"js/" & file & "\")"
     r = r & src
  r = r & "}.toTable"
  debugEcho(r)
  result.add(parseStmt(r))

bundleUpJavascript()

proc getBundledFilenames*(): seq[string] =
  toSeq(keys(bundledJs))

proc sourceForBundledFilename*(name: string): string =
  bundledJs[name]
