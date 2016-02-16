{.compile: "vendor/duktape/duktape.c", passL: "-lm".}

type DuktapeContextObj {.final.} = object
type DuktapeContext* = ptr DuktapeContextObj

proc duk_create_heap*(allocFunc: pointer, reallocFunc: pointer, freeFunc: pointer, userData: pointer, fatalHandlerFunc: pointer): DuktapeContext {.importc.}
proc duk_destroy_heap*(ctx: DuktapeContext) {.importc.}
proc duk_json_encode*(ctx: DuktapeContext, index: cint): cstring {.importc.}
proc duk_json_decode*(ctx: DuktapeContext, index: cint) {.importc.}
proc duk_push_c_function*(ctx: DuktapeContext, funcPtr: pointer, nargs: cint): cint {.importc.}
proc duk_push_current_function*(ctx: DuktapeContext) {.importc.}
proc duk_push_global_object*(ctx: DuktapeContext) {.importc.}
proc duk_get_string*(ctx: DuktapeContext, index: cint): cstring {.importc.}
proc duk_push_string*(ctx: DuktapeContext, str: cstring): cstring {.importc.}
proc duk_to_pointer*(ctx: DuktapeContext, index: cint): pointer {.importc.}
proc duk_safe_to_lstring*(ctx: DuktapeContext, index: cint, outLen: clong): cstring {.importc.}
proc duk_push_pointer*(ctx: DuktapeContext, raw: pointer) {.importc.}
proc duk_put_global_string*(ctx: DuktapeContext, key: cstring): cint {.importc.}
proc duk_get_prop_string*(ctx: DuktapeContext, objIndex: cint, key: cstring): cint {.importc.}
proc duk_put_prop_string*(ctx: DuktapeContext, objIndex: cint, key: cstring): cint {.importc.}
proc duk_pop*(ctx: DuktapeContext) {.importc.}
proc duk_pcall*(ctx: DuktapeContext, nargs: cint): cint {.importc.}
proc duk_eval_raw*(ctx: DuktapeContext, src: cstring, srcLength: clong, flags: cuint): cint {.importc.}

const
  DUK_COMPILE_EVAL* = (1 shl 0)
  DUK_COMPILE_FUNCTION* = (1 shl 1)
  DUK_COMPILE_STRICT* = (1 shl 2)
  DUK_COMPILE_SAFE* = (1 shl 3)
  DUK_COMPILE_NORESULT* = (1 shl 4)
  DUK_COMPILE_NOSOURCE* = (1 shl 5)
  DUK_COMPILE_STRLEN* = (1 shl 6)
