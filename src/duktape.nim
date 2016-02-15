import json
import strutils

{.link: "duktape_c.a".}

type DuktapeContextObj {.final.} = object
type DuktapeContext* = ptr DuktapeContextObj

proc execJavascript*(ctx: DuktapeContext, src: cstring): cstring {.importc.}
proc execJavascriptWithArgs*(ctx: DuktapeContext, funcx: cstring, args: openArray[cstring], argc: cint): cstring {.importc.}

proc duk_create_heap(allocFunc: pointer, reallocFunc: pointer, freeFunc: pointer, userData: pointer, fatalHandlerFunc: pointer): DuktapeContext {.importc.}
proc duk_destroy_heap(ctx: DuktapeContext) {.importc.}
proc duk_json_encode(ctx: DuktapeContext, index: cint): cstring {.importc.}
proc duk_json_decode(ctx: DuktapeContext, index: cint) {.importc.}
proc duk_push_c_function*(ctx: DuktapeContext, funcPtr: pointer, nargs: cint): cint {.importc.}
proc duk_push_current_function*(ctx: DuktapeContext) {.importc.}
proc duk_get_string*(ctx: DuktapeContext, index: cint): cstring {.importc.}
proc duk_push_string*(ctx: DuktapeContext, str: cstring): cstring {.importc.}
proc duk_to_pointer*(ctx: DuktapeContext, index: cint): pointer {.importc.}
proc duk_push_pointer*(ctx: DuktapeContext, raw: pointer) {.importc.}
proc duk_put_global_string*(ctx: DuktapeContext, key: cstring): cint {.importc.}
proc duk_get_prop_string*(ctx: DuktapeContext, objIndex: cint, key: cstring): cint {.importc.}
proc duk_put_prop_string*(ctx: DuktapeContext, objIndex: cint, key: cstring): cint {.importc.}
proc duk_pop*(ctx: DuktapeContext) {.importc.}


proc fatalHandler*(ctx: DuktapeContext, errCode: cint, message: cstring) {.exportc.} =
  let debugMsg = "error code: $1, message: $2" % [$errCode, $message]
  echo(debugMsg)

proc createNewContext*(): DuktapeContext =
  result = duk_create_heap(nil, nil, nil, nil, fatalHandler)

proc destroyContext*(ctx: DuktapeContext) =
  duk_destroy_heap(ctx)

proc callbacker(ctx: DuktapeContext): cint {.exportc.} =
  duk_push_current_function(ctx)
  discard duk_get_prop_string(ctx, -1, "rawProc")
  let rawP = duk_to_pointer(ctx, -1)
  duk_pop(ctx) # rawProc

  discard duk_get_prop_string(ctx, -1, "rawEnv")
  let rawE = duk_to_pointer(ctx, -1)
  duk_pop(ctx) # rawEnv
  duk_pop(ctx) # current function

  let jsonStr = $duk_json_encode(ctx, -1)
  let json = parseJson(jsonStr)

  let cb = cast[proc(json: JsonNode, e: pointer): JsonNode {.cdecl.}](rawP)
  let retJson = cb(json, rawE)
  let retJsonStr = $retJson
  discard duk_push_string(ctx, retJsonStr)
  duk_json_decode(ctx, -1)

  result = 1

proc registerProc*(ctx: DuktapeContext, name: string, op: proc(json: JsonNode): JsonNode) =
  let rawP = rawProc(op)
  let rawE = rawEnv(op)

  discard duk_push_c_function(ctx, callbacker, 1)

  duk_push_pointer(ctx, rawP)
  discard duk_put_prop_string(ctx, -2, "rawProc")

  duk_push_pointer(ctx, rawE)
  discard duk_put_prop_string(ctx, -2, "rawEnv")

  discard duk_put_global_string(ctx, name)

proc registerRawProc*(ctx: DuktapeContext, name: string, op: proc(ctx: DuktapeContext): cint) =
  let raw = rawProc(op)
  discard duk_push_c_function(ctx, raw, 1)
  discard duk_put_global_string(ctx, name)
