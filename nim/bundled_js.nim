import macros, strutils, tables, sequtils

macro bundleUpJavascript(): expr =
  let s = staticExec "(cd js && find . -name '*.js' -exec basename {} \\;)"
  let files = s.splitLines
  result = newStmtList()
  # TODO: something far less inefficent than string concat. stdlib rope is better
  var r = ""
  r = r & """const bundledJs = {"_": nil"""
  for file in files:
     hint("Babelifying $1" % [file])
     let src = """, "$1": staticExec("vendor/Nim/bin/nim c -r --verbosity:0 nim/babelify.nim 2>/dev/null", staticRead("../js/$1"), "0.1")""" % [file]
     r = r & src
  r = r & """
    , "underscore.js": staticRead("../vendor/underscore/underscore.js")
  """
  r = r & "}.toTable"
  result.add(parseStmt(r))

bundleUpJavascript()

macro checker(): expr =
  result = newStmtList()
  var babelErrors = newSeq[string]()

  for k, v in bundledJs:
    # todo: looking for a string is lame, how can we check exit code of staticExec?
    if contains(v, "Babelifying failed"):
      add(babelErrors, v)

  if len(babelErrors) > 0:
    error("Babelifying errors:\n" & join(babelErrors, "\n"))
checker()

proc getBundledFilenames*(): seq[string] =
  toSeq(keys(bundledJs))

proc sourceForBundledFilename*(name: string): string =
  bundledJs[name]
