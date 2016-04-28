import unittest
import osproc
import json

suite "swiftlint tests":
  test "swiftlint integration test":
    let (outp, exitCode) = execCmdEx("nim/ghcs js swiftlint --path tests/fixtures/swiftlint.json")
    let actual = parseJSON(outp)
    let expected = parseJSON("""
      {
        "HEAD": {
          "swiftlint": {
            "comments": [
              {
                "body": "if,for,while,do statements shouldn't wrap their conditionals in parentheses.", 
                "line": 15, 
                "path": "/Users/aidan/dev/ghcs-nim/wat/wat/wat/ErrorHandler.swift"
              }
            ], 
            "metadata": {
              "warningCount": 1
            }, 
            "status": {
              "context": "swiftlint", 
              "description": "Swiftlint found 1 violations", 
              "state": "failure", 
              "target_url": ""
            }
          }
        }
      }
    """)

    check(actual == expected)

  test "only passes through warnings on changed lines":
    discard
    # TODO
