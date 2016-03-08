% ghcs(1)
% Aidan Steele - aidan@awsteele.com

# NAME

ghcs - The GitHub Commit Status thing.

# SYNOPSIS

**ghcs** get [--ref *sha*] *context* ...

**ghcs** set ...

**ghcs** js *script* ...

# DESCRIPTION

This tool is designed to make it dead simple to integrate your custom CI hacks
with GitHub's awesome "commit status" support. See (ancient) screenshot if you
don't know what that is:

To make the barrier to entry as low as possible, Ghcs is packaged as a single
standalone binary and uses JSON over Unix pipes to delegate the heavy lifting
to other tools. Where a tool doesn't understand Ghcs' format (likely), Ghcs
includes a small JavaScript runtime for executing single-source bespoke artisan
scripts as glue.

# EXAMPLES

## Getting commit status

```
$ ghcs get --ref some_git_ref rubocop_ctx
{
  "HEAD": {
    "rubocop_ctx": {
      "metadata": {
        "hello": "world",
        "key": "value",
        "normal": [
          "json"
        ]
      },
      "status": {
        "created_at": "2012-07-20T01:19:13Z",
        "updated_at": "2012-07-20T01:19:13Z",
        "state": "success",
        "target_url": "https://ci.example.com/1000/output",
        "description": "Build has completed successfully",
        "id": 1,
        "url": "https://api.github.com/repos/octocat/Hello-World/statuses/1",
        "context": "rubocop_ctx"
      }
    },
    "git": {
      "sha": "7638417db6d59f3c431d3e1f261cc637155684cd"
    }
  },
  "master": {"...": "..."},
  "HEAD^1": {"...": "..."}
}
```

## Setting commit status

```
$ cat | ghcs set
{
  "HEAD": {
    "rubocop_ctx": {
      "status": {
        "state": "failure",
        "target_url": "http://example.com/123",
        "description": "Rubocop found 72 code style violations (!)",
        "context": "rubocop_ctx"
      },
      "comments": [
        {
          "path": "src/path/to/file.js",
          "line": 47,
          "body": "Prefer single-quoted strings when you don't need string interpolation or special symbols."
        },
        {
          "body": "I'm generally displeased."
        }
      ],
      "metadata": {
        "violation_count": 72
      }
    }
  }
}
^D
{"success":true}
```

## Executing JavaScript

```
$ cat | ghcs execjs path/to/script.js
var x = {hello: "world"};
x.key = 123;

var out = JSON.stringify(x);
Ghcs.stdout(out);
^D
{"hello":"world","key":123}
```

To minimise external dependencies, the JavaScript engine is _not_ Node.js.
Therefore the Node.js stdlib is unavailable. For an exhaustive list of
functionality available inside Ghcs scripts, see [here]().

# SEE ALSO
