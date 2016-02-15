import github_api
import ghkv
import json_kv
import json
import myutils
import git_config
import tables

type
  GhcsRepo* = ref object of RootObj
    api: GithubApi
    kv: JsonKv
    repoName: string

proc newGhcsRepo*(api: GithubApi, repo: string): GhcsRepo =
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

proc ghcsOutput*(repo: GhcsRepo, config: GitConfig, context: string): JsonNode =
  let output = newJObject()
  let relevantRefs = toTable({ "HEAD": config.sha, "HEAD^1": config.sha & "^1", "master": "master" })

  for name, commit in relevantRefs:
    let refOutput = ghcsRefOutput(repo, commit, context)
    #echo("name: " & name & ", commit: " & commit)
    #echo(refOutput)
    output[name] = refOutput

  result = output
