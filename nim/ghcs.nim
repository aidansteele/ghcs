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
  refName: CommitName
  context: ContextName
  remoteUrl: string
  apiToken: string

proc ghcsGet(opts: GhcsInputOptions): JsonNode =
  let extracted = extractBaseAndRepo(opts.remoteUrl)
  let api = GithubApi(baseUri: extracted.base, token: opts.apiToken)
  let repo = newGhcsRepo(api, extracted.repo)

  if len(string(opts.context)) == 0:
    discard # tell user they are bad
  
  result = ghcsOutput(repo, opts.refName, opts.context)

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
  opts.refName = CommitName(getter("ref", "GHCS_REF", ""))
  opts.context = ContextName(getter("context", "GHCS_CONTEXT", ""))
  opts.remoteUrl = getter("remote-url", "GHCS_REMOTE_URL", "")
  opts.apiToken = getter("api-token", "GHCS_API_TOKEN", "")
    
  if len(opts.apiToken) == 0:
    discard # tell user they are bad
  if len(opts.remoteUrl) == 0:
    opts.remoteUrl = execCmdEx("git config --get remote.origin.url").output.strip()
  if len(string(opts.refName)) == 0:
    opts.refName = CommitName(execCmdEx("git rev-parse HEAD").output.strip())

  return opts
  
proc ghcsSet(opts: GhcsInputOptions, input: JsonNode) =
  let extracted = extractBaseAndRepo(opts.remoteUrl)
  let api = GithubApi(baseUri: extracted.base, token: opts.apiToken)
  let repo = newGhcsRepo(api, extracted.repo)

  for context, data in input.fields["HEAD"].fields: # TODO fixme
    let cliRef = toGhcsCliRef(data)
    ghcsInput(repo, opts.refName, ContextName(context), cliRef)

proc newGhcsStdin(source: Stream): auto =
  result = proc(json: JsonNode): JsonNode =
    result = %*{"stdin": readAll(source)}

proc newGhcsStdout(sink: Stream): auto =
  result = proc(json: JsonNode): JsonNode =
    let str = json["stdout"].str
    write(sink, str)
    result = %*{"noop": true}

proc cmd_setjs(params: seq[string]) =
  let opts = initGhcsInputOptions(params[1..high(params)])

  # do the GET we'll pipe through to the js script
  let getOutput = ghcsGet(opts)
  
  # js sandbox env creation
  let inp = newStringStream($getOutput)
  let ghcsStdin = newGhcsStdin(inp)
  let outp = newStringStream()
  let ghcsStdout = newGhcsStdout(outp)
  let cbs = JsCallbackTable(ghcsStdin: ghcsStdin, ghcsStdout: ghcsStdout)

  # now run the script in its sandbox
  let jsExe = newJsExecutor(cbs)
  let cmdParams = optionsTable(params[1..high(params)])    
  let script = cmdParams["script"]   
  let babelify = hasKey(cmdParams, "babelify") # TODO really shouldn't need a val       
  execSourceFile(jsExe, script, babelify)
  destroyJsExecutor(jsExe)

  # now pipe that output back into the SET!
  setPosition(outp, 0)
  let scriptOutputJson = parseJson(readAll(outp))
  ghcsSet(opts, scriptOutputJson)

proc cmd_execjs(params: seq[string]) =
  # TODO: remove duplication of cmd_setjs
  let cmdParams = optionsTable(params[1..high(params)])
  let jsExe = newJsExecutor()
  let script = cmdParams["script"]   
  let babelify = hasKey(cmdParams, "babelify")      
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
    echo(ghcsGet(opts))    
  of "set":
    let opts = initGhcsInputOptions(params[1..high(params)])  
    ghcsSet(opts, parseJson(readAll(stdin)))
  of "setjs":
    cmd_setjs(params)
  of "execjs":
    cmd_execjs(params)
  else:
    echo("Only recognised commands are get, set, execjs")

when not defined(testing):
  doIt()
