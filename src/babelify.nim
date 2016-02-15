import duktape

proc babelifyString*(src: string): string =
  let ctx = createNewContext()

  const babel = staticRead("vendor/babel/babel.js")
  discard execJavascript(ctx, babel)

  discard execJavascript(ctx, """
    function transform(input) {
      var options = { presets: ['es2015'] };
      var babelified = Babel.transform(input, options);
      return babelified.code;
    }
  """)

  let cstr: cstring = src
  result = $execJavascriptWithArgs(ctx, "transform", [cstr], 1)

when isMainModule:
  import os
  var src = ""

  if paramCount() > 0:
    src = readFile(paramStr(1))
  else:
    src = readAll(stdin)

  echo(babelifyString(src))

  # TODO: honestly this belongs anywhere else
  proc readJavascriptSource*(name: cstring, babelify: cint): cstring {.exportc.} =
    result = readFile($name)
