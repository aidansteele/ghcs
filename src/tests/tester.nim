import test_duktape
import test_rubocop

# TODO: honestly this belongs anywhere else
proc readJavascriptSource*(name: cstring, babelify: cint): cstring {.exportc.} =
  result = readFile($name)
