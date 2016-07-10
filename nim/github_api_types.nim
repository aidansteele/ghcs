import json
import strutils
import sequtils
import tables

type
  CommitName* = distinct string
  ContextName* = distinct string

proc `==`*(x, y: CommitName): bool {.borrow.}
proc `==`*(x, y: ContextName): bool {.borrow.}

type PullRequest* = ref object
  baseRef*: CommitName
  headRef*: CommitName
  pullId*: string

proc toPullRequest*(node: JsonNode): PullRequest =
  result = PullRequest(
    baseRef: CommitName(node.fields["base"].fields["sha"].str),
    headRef: CommitName(node.fields["head"].fields["sha"].str),
    pullId: $node["number"].num
  )

type CommitStatusState* {.pure.} = enum
  failure, pending, success

type CommitStatus* = ref object
  state*: CommitStatusState
  targetUrl*: string
  description*: string
  context*: ContextName
  sourceNode: JsonNode

converter toCommitStatus*(node: JsonNode): CommitStatus =
  let state = parseEnum[CommitStatusState](getStr(node["state"]))
  result = CommitStatus(
    state: state,
    targetUrl: getStr(node["target_url"]),
    description: getStr(node["description"]),
    context: ContextName(getStr(node["context"])),
    sourceNode: copy(node)
  )

converter toJson*(cs: CommitStatus): JsonNode =
  result = cs.sourceNode
  result["state"] = %($cs.state)
  result["target_url"] = %(cs.targetUrl)
  result["description"] = %(cs.description)
  result["context"] = %string(cs.context)

type CombinedCommitStatus* = ref object
  statuses*: seq[CommitStatus]

converter toCombinedCommitStatus*(node: JsonNode): CombinedCommitStatus =
  let statuses = map(node["statuses"].elems, proc(x: JsonNode): CommitStatus = x)
  result = CombinedCommitStatus(statuses: statuses)

type CommitInfo* = ref object
  sha*: string

converter toCommitInfo*(node: JsonNode): CommitInfo =
  result = CommitInfo(sha: node["sha"].str)

converter toJson*(ci: CommitInfo): JsonNode =
  result = %*{ "sha": ci.sha }

when defined(testing):
  import unittest

  suite "github api types":
    test "CommitStatus type <-> JSON round-trip":
      let initialJSON = parseJSON("""
        {
          "created_at": "2012-07-20T01:19:13Z",
          "updated_at": "2012-07-20T01:19:13Z",
          "state": "success",
          "target_url": "https://ci.example.com/1000/output",
          "description": "Build has completed successfully",
          "id": 1,
          "url": "https://api.github.com/repos/octocat/Hello-World/statuses/1",
          "context": "continuous-integration/jenkins"
        }
      """)
      let commitStatus: CommitStatus = initialJSON
      let finalJSON: JsonNode = commitStatus

      check(initialJSON == finalJSON)

    test "CommitStatus type <-> JSON round-trip after modifications":
      let initialJSON = parseJSON("""
        {
          "created_at": "2012-07-20T01:19:13Z",
          "updated_at": "2012-07-20T01:19:13Z",
          "state": "success",
          "target_url": "https://ci.example.com/1000/output",
          "description": "Build has completed successfully",
          "id": 1,
          "url": "https://api.github.com/repos/octocat/Hello-World/statuses/1",
          "context": "continuous-integration/jenkins"
        }
      """)

      let expectedJSON = parseJSON("""
        {
          "created_at": "2012-07-20T01:19:13Z",
          "updated_at": "2012-07-20T01:19:13Z",
          "state": "failure",
          "target_url": "https://ci.example.com/1000/output",
          "description": "Build has completed successfully",
          "id": 1,
          "url": "https://api.github.com/repos/octocat/Hello-World/statuses/1",
          "context": "continuous-integration/jenkins"
        }
      """)

      let commitStatus: CommitStatus = initialJSON
      commitStatus.state = CommitStatusState.failure
      let finalJSON: JsonNode = commitStatus

      check(expectedJSON == finalJSON)
