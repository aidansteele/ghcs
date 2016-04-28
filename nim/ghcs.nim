import github_api
import ghcs_repo
import git_config
import os
import js_executor
import patch
import json

proc ghcsGet(sha: string, context: string) =
  let config = defaultConfig()
  let token = getEnv("GHCS_API_TOKEN")
  let api = GithubApi(baseUri: config.baseUri, token: token)
  let repo = newGhcsRepo(api, config.repoName)
  
  let outp = ghcsOutput(repo, config, context)
  echo(pretty(outp))
  
proc ghcsSet() =
  discard
  
proc ghcsExecJs(script: string) =
  let jsExe = newJsExecutor()
  execSourceFile(jsExe, script)
  destroyJsExecutor(jsExe)

proc doIt() =
  let params = commandLineParams()
  if high(params) == -1:
    echo("Need at least one command")
    return
  
  let cmd = params[0]  
  case cmd
  of "get":
    let sha = params[1]
    let context = params[2]
    ghcsGet(sha, context)
  of "set":
    ghcsSet()
  of "execjs":
    let script = params[1]
    ghcsExecJs(script)
  else:
    echo("Only recognised commands are get, set, execjs")

when not defined(testing):
  doIt()
