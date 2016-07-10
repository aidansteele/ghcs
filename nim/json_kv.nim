import json

import ghkv

type
  JsonKv* = ref object
    kv*: Ghkv

proc get*(kv: JsonKv, key: string): JsonNode =
  let raw = get(kv.kv, key)
  result = if isNil(raw): nil else: parseJson(raw)

proc set*(kv: JsonKv, key: string, value: JsonNode): void =
  let raw = $value
  set(kv.kv, key, raw)
