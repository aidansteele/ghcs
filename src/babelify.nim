import duktape
import json

proc babelifyString*(src: string): string =
  let ctx = createNewContext()

  const babel = JS(staticRead("vendor/babel/babel.js"))
  discard evalJavascript(ctx, babel)

  discard evalJavascript(ctx, JS"""
    function transform(input) {
      var options = { presets: ['es2015'] };
      var babelified = Babel.transform(input.src, options);
      return {code: babelified.code};
    }
  """)

  let json = execJavascriptFunc(ctx, "transform", %*{ "src": src })
  result = json["code"].str

when isMainModule:
  import os
  var src = ""

  if paramCount() > 0:
    src = readFile(paramStr(1))
  else:
    src = readAll(stdin)

  echo(babelifyString(src))
