import babelify
import duktape
import bundled_js
import json
import ghcs_native_js

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
  discard evalJavascript(jsExe.context, """
    function runIt(opts) {
      require(opts.name);
      return {};
     }
  """)
  discard execJavascriptFunc(jsExe.context, "runIt", %*{ "name": name })
  #let src = readJavascriptSource(name, babelify)
  #discard evalJavascript(jsExe.context, src)

proc injectHelperFuncs(jsExe: JSExecutor) =
  registerProc(jsExe.context, "_readJavascriptSourceJson", readThunkJson)
  registerProc(jsExe.context, "_ghcsReadFile", ghcsReadFile)
  registerProc(jsExe.context, "_ghcsStdin", ghcsStdin)
  registerProc(jsExe.context, "_ghcsStdout", ghcsStdout)
  registerProc(jsExe.context, "_ghcsShell", ghcsShell)
  registerProc(jsExe.context, "_ghcsHttp", ghcsHttp)

  let loader = readJavascriptSource("moduleLoader", false)
  discard evalJavascript(jsExe.context, loader)
  #execSourceFile(jsExe, "moduleLoader")

proc newJsExecutor*(): JsExecutor =
  let ctx = createNewContext()
  let jsExe = JsExecutor(context: ctx)
  injectHelperFuncs(jsExe)

  result = jsExe

# TODO: where are the non-experimental destructors?
proc destroyJsExecutor*(jsExe: JSExecutor) =
  destroyContext(jsExe.context)
