
proc findx*[T](data: openArray[T], op: proc(x: T): bool {.closure.}): T {.inline.} =
  result = nil
  for elem in data:
    if op(elem):
      result = elem
      break
