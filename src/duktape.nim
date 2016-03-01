import json
import strutils
import duktape_ffi

# TODO: is there a better way to re-export this?
# i don't want to import duktape_ffi everywhere
type DuktapeContext* = duktape_ffi.DuktapeContext

type JS* = distinct string

proc evalJavascript*(ctx: DuktapeContext, src: JS): string =
  duk_push_global_object(ctx)

  discard duk_push_string(ctx, "filename")
  let flags: cuint = DUK_COMPILE_EVAL or DUK_COMPILE_SAFE or DUK_COMPILE_NOSOURCE or DUK_COMPILE_STRLEN

  let res = duk_eval_raw(ctx, string(src), 0, flags)

  if res != 0:
    discard duk_get_prop_string(ctx, -1, "stack")
    let stack = $duk_safe_to_lstring(ctx, -1, 0)
    echo("Duktape error: $1 from src: $2" % [stack, string(src)])

  result = $duk_safe_to_lstring(ctx, -1, 0)
  duk_pop(ctx)
  duk_pop(ctx)

proc execJavascriptFunc*(ctx: DuktapeContext, funcName: string, args: JsonNode): JsonNode =
  duk_push_global_object(ctx)
  discard duk_get_prop_string(ctx, -1, funcName)

  discard duk_push_string(ctx, $args)
  duk_json_decode(ctx, -1)

  if duk_pcall(ctx, 1) != 0:
    discard duk_get_prop_string(ctx, -1, "stack")
    let stack = $duk_safe_to_lstring(ctx, -1, 0)
    echo("Duktape error: $1" % [stack])

  let jsonStr = $duk_json_encode(ctx, -1)
  result = parseJson(jsonStr)

  duk_pop(ctx)

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
