import babelify
import nimduktape
import bundled_js
import json
import ghcs_native_js
import macros

type
  JsCallback* = proc(json: JsonNode): JsonNode
  JsCallbackTable* = object # TODO: it'd be nicer if this was a table
    readJavascriptSourceJson*: JsCallback
    ghcsReadFile*: JsCallback
    ghcsWriteFile*: JsCallback
    ghcsStdin*: JsCallback
    ghcsStdout*: JsCallback
    ghcsShell*: JsCallback
    ghcsHttp*: JsCallback
    ghcsArgv*: JsCallback

  JsExecutor* = ref object
    context: DuktapeContext
    callbacks: JsCallbackTable

proc readJavascriptSource*(name: string, babelify: bool): JS =
  let bundledName = name & ".js"
  var src = ""

  if bundledName in getBundledFilenames():
    src = sourceForBundledFilename(bundledName)
  else:
    src = readFile($name)

  if babelify:
    src = babelifyString(src)

  result = JS(src)

proc readJavascriptSourceJson(json: JsonNode): JsonNode =
  let name = json["name"].str
  let src = readJavascriptSource(name, false)
  result = %*{ "src": string(src) }

proc execSourceFile*(jsExe: JSExecutor, name: string, babelify = false) =
  # TODO: actually implement babelification
  discard evalJavascript(jsExe.context, JS"""
    function runIt(opts) {
      require(opts.name);
      return {};
     }
  """)
  discard execJavascriptFunc(jsExe.context, "runIt", %*{ "name": name })
  #let src = readJavascriptSource(name, babelify)
  #discard evalJavascript(jsExe.context, src)

proc defaultJsCallbacks(): JsCallbackTable =
  result = JsCallbackTable(
    readJavascriptSourceJson: readJavascriptSourceJson, 
    ghcsReadFile: ghcsReadFile,
    ghcsWriteFile: ghcsWriteFile,
    ghcsStdin: ghcsStdin,
    ghcsStdout: ghcsStdout,
    ghcsShell: ghcsShell,
    ghcsHttp: ghcsHttp,
    ghcsArgv: ghcsArgv
  )

macro stringify(n: expr): string =
  result = newNimNode(nnkStmtList, n)
  result.add(toStrLit(n))

template injectHelper(jsExe, cbt, def, name: expr) =
  let op = if isNil(cbt.`name`): def.`name` else: cbt.`name`
  registerProc(jsExe.context, "_" & stringify(`name`), op) 

proc injectHelperFuncs(jsExe: JSExecutor, cb: JsCallbackTable) =
  let def = defaultJsCallbacks()
  injectHelper(jsExe, cb, def, readJavascriptSourceJson)
  injectHelper(jsExe, cb, def, ghcsReadFile)
  injectHelper(jsExe, cb, def, ghcsWriteFile)
  injectHelper(jsExe, cb, def, ghcsStdin)
  injectHelper(jsExe, cb, def, ghcsStdout)
  injectHelper(jsExe, cb, def, ghcsShell)
  injectHelper(jsExe, cb, def, ghcsHttp)
  injectHelper(jsExe, cb, def, ghcsArgv)

  let loader = readJavascriptSource("moduleLoader", false)
  discard evalJavascript(jsExe.context, loader)

proc newJsExecutor*(callbacks: JsCallbackTable = JsCallbackTable()): JsExecutor =
  let ctx = createNewContext()  
  let jsExe = JsExecutor(context: ctx, callbacks: callbacks)
  injectHelperFuncs(jsExe, callbacks)
  result = jsExe

# TODO: where are the non-experimental destructors?
proc destroyJsExecutor*(jsExe: JSExecutor) =
  destroyContext(jsExe.context)
