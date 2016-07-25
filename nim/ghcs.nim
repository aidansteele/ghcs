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

proc cmd_get(opts: GhcsInputOptions): JsonNode =
  let extracted = extractBaseAndRepo(opts.remoteUrl)
  let api = GithubApi(baseUri: extracted.base, token: opts.apiToken)
  let repo = newGhcsRepo(api, extracted.repo)

  if len(string(opts.context)) == 0:
    discard # tell user they are bad
  if len(opts.apiToken) == 0:
    discard # tell user they are bad
  
  result = ghcsOutput(repo, opts.refName, opts.context)

proc initGhcsInputOptions(cmdParams: StringTableRef): GhcsInputOptions =
  template getter(cli: string, env: string, default: untyped): string =
    if hasKey(cmdParams, cli):
      cmdParams[cli]
    elif existsEnv(env):
      getEnv(env)
    else:
      default

  let exec = proc(cmd: string): string =
    execCmdEx(cmd).output.strip()
  
  var opts: GhcsInputOptions
  opts.refName = CommitName(getter("ref", "GHCS_REF", exec("git rev-parse HEAD")))
  opts.context = ContextName(getter("context", "GHCS_CONTEXT", ""))
  opts.remoteUrl = getter("remote-url", "GHCS_REMOTE_URL", exec("git config --get remote.origin.url"))
  opts.apiToken = getter("api-token", "GHCS_API_TOKEN", "")
  result = opts
  
proc cmd_set(opts: GhcsInputOptions, input: JsonNode) =
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

proc cmd_setjs(cmdParams: StringTableRef) =
  let opts = initGhcsInputOptions(cmdParams)

  # do the GET we'll pipe through to the js script
  let getOutput = cmd_get(opts)
  
  # js sandbox env creation
  let inp = newStringStream($getOutput)
  let ghcsStdin = newGhcsStdin(inp)
  let outp = newStringStream()
  let ghcsStdout = newGhcsStdout(outp)
  let cbs = JsCallbackTable(ghcsStdin: ghcsStdin, ghcsStdout: ghcsStdout)

  # now run the script in its sandbox
  let jsExe = newJsExecutor(cbs)
  let script = cmdParams["script"]   
  let babelify = hasKey(cmdParams, "babelify") # TODO really shouldn't need a val       
  execSourceFile(jsExe, script, babelify)
  destroyJsExecutor(jsExe)

  # now pipe that output back into the SET!
  setPosition(outp, 0)
  let scriptOutputJson = parseJson(readAll(outp))
  cmd_set(opts, scriptOutputJson)

proc cmd_execjs(cmdParams: StringTableRef) =
  # TODO: remove duplication of cmd_setjs
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
  let cmdParams = optionsTable(params[1..high(params)])
  let opts = initGhcsInputOptions(cmdParams)
  
  case cmd
  of "get":
    echo(cmd_get(opts))    
  of "set":
    cmd_set(opts, parseJson(readAll(stdin)))
  of "setjs":
    cmd_setjs(cmdParams)
  of "execjs":
    cmd_execjs(cmdParams)
  else:
    echo("Only recognised commands are get, set, execjs")

when not defined(testing):
  doIt()
