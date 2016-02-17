import json
import strutils
import sequtils

type CommitStatusState = enum
  failure, pending, success

type CommitStatus* = ref object of RootObj
  state*: CommitStatusState
  targetUrl*: string
  description*: string
  context*: string

converter toCommitStatus*(node: JsonNode): CommitStatus =
  let state = parseEnum[CommitStatusState]($node["state"].str)
  result = CommitStatus(state: state, targetUrl: $node["target_url"].str, description: $node["description"].str, context: $node["context"].str)

converter toJson*(cs: CommitStatus): JsonNode =
  result = %*{ "state": $cs.state, "target_url": cs.targetUrl, "description": cs.description, "context": cs.context }

type CombinedCommitStatus* = ref object of RootObj
  statuses*: seq[CommitStatus]

converter toCombinedCommitStatus*(node: JsonNode): CombinedCommitStatus =
  let statuses = map(node["statuses"].elems, proc(x: JsonNode): CommitStatus = x)
  result = CombinedCommitStatus(statuses: statuses)
