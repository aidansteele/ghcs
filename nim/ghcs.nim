import github_api
import ghcs_repo
import git_config
import os
import osproc
import js_executor
import json
import options_table
import strtabs
import streams
import tables
import strutils
import github_api_types

type GhcsInputOptions* = object
  refName: string
  context: string
  baseBranch: string
  remoteUrl: string
  apiToken: string

proc ghcsGet(opts: GhcsInputOptions) =
  let extracted = extractBaseAndRepo(opts.remoteUrl)
  let api = GithubApi(baseUri: extracted.base, token: opts.apiToken)
  let repo = newGhcsRepo(api, extracted.repo, opts.baseBranch)

  if len(opts.context) == 0:
    discard # tell user they are bad
  
  let outp = ghcsOutput(repo, CommitName(opts.refName), ContextName(opts.context))
  echo(pretty(outp))

proc initGhcsInputOptions(cliParams: openarray[string]): GhcsInputOptions =
  let cmdParams = optionsTable(cliParams)

  let getter = proc(cli: string, env: string, default: string): string =
    if hasKey(cmdParams, cli):
      return cmdParams[cli]
    elif existsEnv(env):
      return getEnv(env)
    else:
      return default
  
  var opts: GhcsInputOptions
  opts.refName = getter("ref", "GHCS_REF", "")
  opts.context = getter("context", "GHCS_CONTEXT", "")
  opts.baseBranch = getter("base-branch", "GHCS_BASE_BRANCH", "master")
  opts.remoteUrl = getter("remote-url", "GHCS_REMOTE_URL", "")
  opts.apiToken = getter("api-token", "GHCS_API_TOKEN", "")
    
  if len(opts.apiToken) == 0:
    discard # tell user they are bad
  if len(opts.remoteUrl) == 0:
    opts.remoteUrl = execCmdEx("git config --get remote.origin.url").output.strip()
  if len(opts.refName) == 0:
    opts.refName = execCmdEx("git rev-parse HEAD").output.strip()

  return opts
  
proc ghcsSet(opts: GhcsInputOptions, input: Stream) =
  let extracted = extractBaseAndRepo(opts.remoteUrl)
  let api = GithubApi(baseUri: extracted.base, token: opts.apiToken)
  let repo = newGhcsRepo(api, extracted.repo, opts.baseBranch)

  let json = parseJson(input, "stdin")
  for context, data in json.fields["HEAD"].fields: # TODO fixme
    let cliRef = toGhcsCliRef(data)
    ghcsInput(repo, CommitName(opts.refName), ContextName(context), cliRef)

proc ghcsExecJs(script: string, babelify: bool) =
  let jsExe = newJsExecutor()
  execSourceFile(jsExe, script, babelify)
  destroyJsExecutor(jsExe)

proc doIt() =
  let params = commandLineParams()
  if high(params) == -1:
    echo("Need at least one command")
    return
  
  let cmd = params[0]  
  case cmd
  of "get":
    let opts = initGhcsInputOptions(params[1..high(params)])
    ghcsGet(opts)
  of "set":
    let opts = initGhcsInputOptions(params[1..high(params)])  
    ghcsSet(opts, newFileStream(stdin))
  of "execjs":
    let cmdParams = optionsTable(params[1..high(params)])
    let script = cmdParams["script"]
    let babelify = hasKey(cmdParams, "babelify") # TODO really shouldn't need a val  
    ghcsExecJs(script, babelify)
  else:
    echo("Only recognised commands are get, set, execjs")

when not defined(testing):
  doIt()
