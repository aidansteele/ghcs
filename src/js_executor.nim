import babelify
import duktape
import bundled_js

type
  JsExecutor* = ref object of RootObj
    context: DuktapeContext

proc readJavascriptSource*(name: cstring, babelify: cint): cstring {.exportc.} =
  let bundledName = $name & ".js"
  var src = ""

  if bundledName in getBundledFilenames():
    src = sourceForBundledFilename(bundledName)
  else:
    src = readFile($name)

  if babelify > 0:
    src = babelifyString(src)

  result = src

proc execSourceFile*(jsExe: JSExecutor, name: string, babelify = false) =
  let cBabelify: cint = if babelify: 1 else: 0
  var src = $readJavascriptSource(name, cBabelify)
  discard execJavascript(jsExe.context, src)

proc injectHelperFuncs(jsExe: JSExecutor) =
  execSourceFile(jsExe, "moduleLoader")

proc newJsExecutor*(): JsExecutor =
  let ctx = createNewContext()
  let jsExe = JsExecutor(context: ctx)
  injectHelperFuncs(jsExe)

  result = jsExe

# TODO: where are the non-experimental destructors?
proc destroyJsExecutor*(jsExe: JSExecutor) =
  destroyContext(jsExe.context)
