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
