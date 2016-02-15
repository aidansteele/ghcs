
#include "duktape.h"

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
