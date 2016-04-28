import osproc
import uri
import strutils
import os
import nre

type
  GitConfig* = tuple
    repoName: string
    baseUri: Uri
    sha: string

proc normalisedRemoteUri(remote: string): Uri =
  var rem = remote
  
  if not (startsWith(remote, "http") or startsWith(remote, "ssh")):
    rem = "ssh://" & rem
  
  if startsWith(rem, "ssh"):
    rem = replace(rem, re"ssh://([^:]+):", "ssh://$1/")
  
  rem = replace(rem, "ssh://", "https://")  
  result = parseUri(rem)
  
proc extractBaseAndRepo(remote: string): tuple[base: Uri, repo: string] =
  var uri = normalisedRemoteUri(remote)
  var repoName = uri.path[1..len(uri.path)]
  removeSuffix(repoName, ".git")
  
  uri.path = "/"
  uri.username = ""
  
  # public github special case!
  if uri.hostname == "github.com":
    uri.hostname = "api.github.com"
  
  result = (uri, repoName)

proc defaultConfig*(): GitConfig =
  result = (repoName: "glassechidna/ghkv", baseUri: parseUri("https://api.github.com/"), sha: "06e5c6da7f09c22c015d39701b356ba558134992^1")

proc localConfig*(path: string = "."): GitConfig =
  let cmdInPath = proc(cmd: string): string =
    let it = "(cd $1 && $2)" % [path, cmd] 
    execCmdEx(it).output
    
  let remote = cmdInPath("git config --get remote.origin.url")
  let sha = cmdInPath("git rev-parse HEAD")
  let it = extractBaseAndRepo(remote)
  result = (repoName: it.repo, baseUri: it.base, sha: sha)  

proc envConfig*(): GitConfig =
  let sha = getEnv("GHCS_SHA")
  let remote = getEnv("GHCS_REMOTE")
  let url = getEnv("GHCS_API_URL")
  
  let it = extractBaseAndRepo(remote)
  result = (repoName: it.repo, baseUri: parseUri(url), sha: sha)
  echo result
  
when defined(testing):
  import unittest
  suite "git config tests":
    test "handles public github special case":
      let remote = "https://github.com/aidansteele/ghcs.git"
      let it = extractBaseAndRepo(remote)
      check(it.base == parseUri("https://api.github.com/"))
  
    test "splits up ssh url without scheme":
      let remote = "git@github.com:aidansteele/ghcs.git"
      let it = extractBaseAndRepo(remote)
      check(it.repo == "aidansteele/ghcs")
      
    test "splits up ssh url with scheme":
      let remote = "ssh://git@github.com:aidansteele/ghcs.git"
      let it = extractBaseAndRepo(remote)
      check(it.repo == "aidansteele/ghcs")
    
    # TODO: test if setting api envvar (but not other envvars) works, e.g. GHE
