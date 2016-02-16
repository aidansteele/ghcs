import unittest
import duktape
import json

suite "js executor tests":
  test "simple string literal hello world js execution":
    let ctx = createNewContext()
    let response = evalJavascript(ctx, """
      function hw() {
        return "hello, world!"
      }
      hw()
    """)

    check(response == "hello, world!")
    destroyContext(ctx)

  test "exec func with args":
    let ctx = createNewContext()
    discard evalJavascript(ctx, """
      function hw(args) {
        return {resp: "hello, world of " + args.name}
      }
    """)

    let cstr: cstring = "arg0"
    let args = %*{ "name": "duktape" }
    let response = execJavascriptFunc(ctx, "hw", args)
    check(response["resp"].str == "hello, world of duktape")
    destroyContext(ctx)
