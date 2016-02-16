import babelify
import duktape
import bundled_js
import json

type
  JsExecutor* = ref object of RootObj
    context: DuktapeContext

proc readJavascriptSource*(name: string, babelify: bool): string =
  let bundledName = name & ".js"
  var src = ""

  if bundledName in getBundledFilenames():
    src = sourceForBundledFilename(bundledName)
  else:
    src = readFile($name)

  if babelify:
    src = babelifyString(src)

  result = src

proc readThunkJson(json: JsonNode): JsonNode =
  let name = json["name"].str
  let src = readJavascriptSource(name, false)
  result = %*{ "src": src }

proc execSourceFile*(jsExe: JSExecutor, name: string, babelify = false) =
  let src = readJavascriptSource(name, babelify)
  discard evalJavascript(jsExe.context, src)

proc injectHelperFuncs(jsExe: JSExecutor) =
  registerProc(jsExe.context, "_readJavascriptSourceJson", readThunkJson)
  execSourceFile(jsExe, "moduleLoader")

proc newJsExecutor*(): JsExecutor =
  let ctx = createNewContext()
  let jsExe = JsExecutor(context: ctx)
  injectHelperFuncs(jsExe)

  result = jsExe

# TODO: where are the non-experimental destructors?
proc destroyJsExecutor*(jsExe: JSExecutor) =
  destroyContext(jsExe.context)
