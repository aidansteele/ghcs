
#include "duktape.h"

duk_context *createNewContext()
{
  duk_context *ctx = duk_create_heap_default();
  return ctx;
}

void execJavascript(duk_context *ctx, const char *src)
{
  duk_eval_string(ctx, src);
}

void destroyContext(duk_context *ctx)
{
  duk_destroy_heap(ctx);
}

