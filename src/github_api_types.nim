import json
import strutils
import sequtils

type CommitStatusState* {.pure.} = enum
  failure, pending, success

type CommitStatus* = ref object of RootObj
  state*: CommitStatusState
  targetUrl*: string
  description*: string
  context*: string
  sourceNode: JsonNode

converter toCommitStatus*(node: JsonNode): CommitStatus =
  let state = parseEnum[CommitStatusState](getStr(node["state"]))
  result = CommitStatus(
    state: state,
    targetUrl: getStr(node["target_url"]),
    description: getStr(node["description"]),
    context: getStr(node["context"]),
    sourceNode: copy(node)
  )

converter toJson*(cs: CommitStatus): JsonNode =
  result = cs.sourceNode
  result["state"] = %($cs.state)
  result["target_url"] = %(cs.targetUrl)
  result["description"] = %(cs.description)
  result["context"] = %(cs.context)

type CombinedCommitStatus* = ref object of RootObj
  statuses*: seq[CommitStatus]

converter toCombinedCommitStatus*(node: JsonNode): CombinedCommitStatus =
  let statuses = map(node["statuses"].elems, proc(x: JsonNode): CommitStatus = x)
  result = CombinedCommitStatus(statuses: statuses)

type CommitInfo* = ref object of RootObj
  sha*: string
  sourceNode: JsonNode

converter toCommitInfo*(node: JsonNode): CommitInfo =
  result = CommitInfo(sha: node["sha"].str, sourceNode: copy(node))

converter toJson*(ci: CommitInfo): JsonNode =
  result = ci.sourceNode
  result["sha"] = %(ci.sha)
