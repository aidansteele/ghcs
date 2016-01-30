# ghcs

[![Build Status](https://travis-ci.org/aidansteele/ghcs.svg?branch=master)](https://travis-ci.org/aidansteele/ghcs)

The GitHub Commit Status thing.

This tool is designed to make it dead simple to integrate your custom CI hacks
with GitHub's awesome "commit status" support. See (ancient) screenshot if you
don't know what that is:

![76b6b1c4-2bcc-11e5-8b03-55801f8ff09a](https://cloud.githubusercontent.com/assets/369053/12695377/44cc1350-c7a0-11e5-98ed-8accfe082977.png)

To make the barrier to entry as low as possible, Ghcs is packaged as a single
standalone binary and uses JSON over Unix pipes to delegate the heavy lifting
to other tools. Where a tool doesn't understand Ghcs' format (likely), Ghcs
includes a small JavaScript runtime for executing single-source bespoke artisan
scripts as glue. Example theoretical usage:

```
$ ghcs get --ref deadbeef rubocop_ctx | ./some_rubocop_wrapper | ghcs set
```

## Usage

### Getting commit status

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
    "github": {
      "sha": "7638417db6d59f3c431d3e1f261cc637155684cd",
      "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/7638417db6d59f3c431d3e1f261cc637155684cd",
      "author": {
        "date": "2014-11-07T22:01:45Z",
        "name": "Scott Chacon",
        "email": "schacon@gmail.com"
      },
      "committer": {
        "date": "2014-11-07T22:01:45Z",
        "name": "Scott Chacon",
        "email": "schacon@gmail.com"
      },
      "message": "added readme, because im a good github citizen\n",
      "tree": {
        "url": "https://api.github.com/repos/octocat/Hello-World/git/trees/691272480426f78a0138979dd3ce63b77f706feb",
        "sha": "691272480426f78a0138979dd3ce63b77f706feb"
      },
      "parents": [
        {
          "url": "https://api.github.com/repos/octocat/Hello-World/git/commits/1acc419d4d6a9ce985db7be48c6349a0475975b5",
          "sha": "1acc419d4d6a9ce985db7be48c6349a0475975b5"
        }
      ]
    }
  },
  "master": {"...": "..."},
  "HEAD^1": {"...": "..."}
}
```

### Setting commit status

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
      "metadata": {
        "violation_count": 72
      }
    }
  }
}
^D
{"success":true}
```

### Executing JavaScript

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
