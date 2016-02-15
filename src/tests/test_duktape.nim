import unittest
import duktape

suite "js executor tests":
  test "simple string literal hello world js execution":
    let ctx = createNewContext()
    let response = $execJavascript(ctx, """
      function hw() {
        return "hello, world!"
      }
      hw()
    """)

    check(response == "hello, world!")
    destroyContext(ctx)

  test "exec func with args":
    let ctx = createNewContext()
    discard execJavascript(ctx, """
      function hw(args) {
        return "hello, world of " + args
      }
    """)

    let cstr: cstring = "arg0"
    let response = $execJavascriptWithArgs(ctx, "hw", [cstr], 1)
    check(response == "hello, world of arg0")
    destroyContext(ctx)
