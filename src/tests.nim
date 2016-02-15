#!/usr/bin/env nim c -r

import unittest
import duktape

suite "js executor tests":
  test "simple hello world js execution":
    let ctx = createNewContext()
    let response = $execJavascript(ctx, """
      function hw() {
        return "hello, world!"
      }
      hw()
    """)

    check(response == "hello, world!")
    destroyContext(ctx)

# TODO: find a better solution for this
when isMainModule:
  proc readJavascriptSource*(name: cstring, babelify: cint): cstring {.exportc.} =
    result = readFile($name)
