import sequtils
import json
import osproc
import tables
import os

import github_api
import ghkv

import duktape

import json_kv
import myutils
import git_config

type
  GhcsRepo* = ref object of RootObj
    api: GithubApi
    kv: JsonKv
    repoName: string

proc newGhcsRepo(api: GithubApi, repo: string): GhcsRepo =
  let rawKv = newGhkv(api, repo)
  let jsonKv = JsonKv(kv: rawKv)
  result = GhcsRepo(api: api, kv: jsonKv, repoName: repo)

proc commitInfo(repo: GhcsRepo, commitName: string): JsonNode =
  let url = "repos/" & repo.repoName & "/commits/" & commitName
  result = request(repo.api, "GET", url)

proc commitStatus(repo: GhcsRepo, commitName: string, context: string): JsonNode =
  let url = "repos/" & repo.repoName & "/commits/" & commitName & "/status"
  let resp = request(repo.api, "GET", url)
  let statuses = resp["statuses"].elems
  let op = proc(x: JsonNode): bool =
    $x["context"].str == context
  result = findx(statuses, op)

proc commitMetadata(repo: GhcsRepo, commitName: string, context: string): JsonNode =
  let key = "metadata_" & context & "_" & commitName
  let resp = get(repo.kv, key)
  result = if isNil(resp): newJObject() else: resp

proc ghcsRefOutput(repo: GhcsRepo, commitName: string, context: string): JsonNode =
  let info = commitInfo(repo, commitName)
  let sha = info["sha"].str
  let status = commitStatus(repo, sha, context)
  let metadata = commitMetadata(repo, sha, context)

  result = newJObject()
  result["github"] = info
  let contextOutput = newJObject()
  contextOutput["metadata"] = metadata
  contextOutput["status"] = if isNil(status): newJNull() else: status
  result[context] = contextOutput

let config = defaultConfig()
let token = getEnv("GHCS_API_TOKEN")
let api = GithubApi(baseUrl: config.baseUrl, token: token)
let repo = newGhcsRepo(api, config.repoName)

proc ghcsOutput(repo: GhcsRepo, config: GitConfig, context: string): JsonNode =
  let output = newJObject()
  let relevantRefs = toTable({ "HEAD": config.sha, "HEAD^1": config.sha & "^1", "master": "master" })

  for name, commit in relevantRefs:
    let refOutput = ghcsRefOutput(repo, commit, context)
    #echo("name: " & name & ", commit: " & commit)
    #echo(refOutput)
    output[name] = refOutput

  result = output

import bundled_js
echo($getBundledFilenames())
let src = sourceForBundledFilename("js/test.js")

type
  JsExecutor = ref object of RootObj
    context: DuktapeContext

proc babelifyString*(src: string): string =
  let ctx = createNewContext()

  let babel = sourceForBundledFilename("js/babel.js")
  discard execJavascript(ctx, babel)

  discard execJavascript(ctx, """
    function transform(input) {
      var options = { presets: ['es2015'] };
      var babelified = Babel.transform(input, options);
      return babelified.code;
    }
  """)

  let cstr: cstring = src
  result = $execJavascriptWithArgs(ctx, "transform", [cstr], 1)

proc execSourceFile(jsExe: JSExecutor, name: string, babelify = false) =
  let bundledName = "js/" & name & ".js"
  var src = ""

  if bundledName in getBundledFilenames():
    src = sourceForBundledFilename(bundledName)
  else:
    src = readFile(name)

  if babelify:
    src = babelifyString(src)

  echo(src)
  discard execJavascript(jsExe.context, src)

proc injectHelperFuncs(jsExe: JSExecutor) =
  execSourceFile(jsExe, "ghcs", true)

proc newJsExecutor(): JsExecutor =
  let ctx = createNewContext()
  let jsExe = JsExecutor(context: ctx)
  injectHelperFuncs(jsExe)

  result = jsExe

# TODO: where are the non-experimental destructors?
proc destroyJsExecutor(jsExe: JSExecutor) =
  destroyContext(jsExe.context)

import os

let jsExe = newJsExecutor()
execSourceFile(jsExe, paramStr(1), true)
destroyJsExecutor(jsExe)

#echo(pretty(ghcsOutput(repo, config, "moomoo")))
# blah
