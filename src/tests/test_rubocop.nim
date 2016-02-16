import unittest
import osproc
import json

suite "rubocop tests":
  test "end-to-end integration test":
    let (outp, exitCode) = execCmdEx("./main js rubocop --path tests/rubocop.json")
    echo("OUTPUT: " & outp) # for travis ci's benefit
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
            }
          }
        }
      }
    """)

    check(actual == expected)
