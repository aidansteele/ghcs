import unittest
import osproc
import json

suite "rubocop tests":
  test "rubocop integration test":
    let (outp, exitCode) = execCmdEx("./ghcs js rubocop --path tests/fixtures/rubocop.json")
    let actual = parseJSON(outp)
    let expected = parseJSON("""
      {
        "HEAD": {
          "rubocop": {
            "status": {
              "state": "failure",
              "description": "Rubocop found 2 violations",
              "target_url": "",
              "context": "rubocop"
            },
            "metadata": {
              "offenseCount": 2
            },
            "comments": [
              {
                "path": "example_file.rb",
                "line": 2,
                "body": "Missing top-level class documentation comment."
              },
              {
                "path": "example_file.rb",
                "line": 4,
                "body": "Prefer single-quoted strings when you don't need string interpolation or special symbols."
              }
            ]
          }
        }
      }
    """)

    check(actual == expected)

  test "only passes through warnings on changed lines":
    discard
    # TODO
