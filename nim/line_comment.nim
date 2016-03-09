import patch
import sequtils
import json
import math

type LineComment* = tuple[path: string, lineNumber: int, comment: string]

proc applicableLineComments*(comments: seq[LineComment], changedLines: seq[ChangedLine]): seq[LineComment] =
  result = filter(comments) do (lc: LineComment) -> bool:
    any(changedLines) do (cl: ChangedLine) -> bool:
      cl.lineNumber == lc.lineNumber

converter toLineComment*(node: JsonNode): LineComment =
  let ln = cast[int](getNum(node["line"]))
  result = (path: getStr(node["path"]), lineNumber: ln, comment: getStr(node["body"]))

converter toJson*(lc: LineComment): JsonNode =
  result = %*{ "path": lc.path, "line": lc.lineNumber, "body": lc.comment }
