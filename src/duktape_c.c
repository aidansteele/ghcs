
#include "duktape.h"

extern const char *readJavascriptSource(const char *name, int babelify);
duk_ret_t readJavascriptSourceThunk(duk_context *ctx);

void dukFatalHandler(duk_context *ctx, duk_errcode_t code, const char *msg)
{
  printf("error code: %d, message: %s\n", code, msg);
  abort();
}

duk_context *createNewContext()
{
  duk_context *ctx = duk_create_heap(NULL, NULL, NULL, NULL, dukFatalHandler);
  duk_push_c_function(ctx, readJavascriptSourceThunk, 1);
  duk_put_global_string(ctx, "_readJavascriptSource");
  return ctx;
}

duk_ret_t readJavascriptSourceThunk(duk_context *ctx)
{
  const char *name = duk_get_string(ctx, -1);
  const char *str = readJavascriptSource(name, 1);
  duk_push_string(ctx, str);
  return 1;
}

const char *execJavascript(duk_context *ctx, const char *src)
{
  duk_push_global_object(ctx);

  if (duk_peval_string(ctx, src) != 0)
  {
    printf("eval failed: %s\n", duk_safe_to_string(ctx, -1));
    duk_pop_2(ctx);
  }
  else
  {
    const char *ret = duk_get_string(ctx, -1);
    duk_pop_2(ctx);
    return ret;
  }
}

void destroyContext(duk_context *ctx)
{
  duk_destroy_heap(ctx);
}

const char *execJavascriptWithArgs(duk_context *ctx, const char *func, const char **args, int argc)
{
  duk_push_global_object(ctx);
  duk_get_prop_string(ctx, -1, func);

  for (int i = 0; i < argc; i++)
  {
    duk_push_string(ctx, args[i]);
  }

  duk_pcall(ctx, argc);
  return duk_get_string(ctx, -1);
}
