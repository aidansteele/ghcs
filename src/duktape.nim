
{.link: "duktape_c.a".}

type DuktapeContextObj {.final.} = object
type DuktapeContext* = ptr DuktapeContextObj

proc createNewContext*(): DuktapeContext {.importc.}
proc destroyContext*(ctx: DuktapeContext): void {.importc.}
proc execJavascript*(ctx: DuktapeContext, src: cstring): void {.importc.}
