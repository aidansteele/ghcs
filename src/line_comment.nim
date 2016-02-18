import patch
import sequtils

type LineComment* = tuple[lineNumber: int, comment: string]

proc applicableLineComments*(comments: seq[LineComment], changedLines: seq[ChangedLine]): seq[LineComment] =
  result = filter(comments) do (lc: LineComment) -> bool:
    any(changedLines) do (cl: ChangedLine) -> bool:
      cl.lineNumber == lc.lineNumber
