import osproc

type
  GitConfig* = tuple
    repoName: string
    baseUrl: string
    sha: string

proc defaultConfig*(): GitConfig =
  result = (repoName: "glassechidna/ghkv", baseUrl: "https://api.github.com/", sha: "06e5c6da7f09c22c015d39701b356ba558134992^1")

proc localConfig*(path: string = "."): GitConfig =
  let cmdInPath = proc(cmd: string): string = execCmdEx("(cd " & path & " && " & cmd & ")").output
  let sha = cmdInPath("git rev-parse HEAD")
  let url = "https://api.github.com/" # cmdInPath("git config --get remote.origin.url")
  let repoName = "glassechidna/ghkv" # cmdInPath("git config --get remote.origin.url")
  result = (repoName: repoName, baseUrl: url, sha: sha)
