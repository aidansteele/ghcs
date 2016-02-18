import unittest
import github_api_types
import json

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
