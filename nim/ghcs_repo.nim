import github_api
import github_api_types
import ghkv
import json_kv
import json
import myutils
import git_config
import tables
import sequtils
import github_api_types
import line_comment

type
  GhcsCliRef* = ref object of RootObj
    metadata: JsonNode
    status: CommitStatus
    comments: seq[LineComment]
    commitInfo: CommitInfo

  GhcsCliOutput* = seq[tuple[name: string, cliRef: GhcsCliRef]]

  GhcsRepo* = ref object of RootObj
    api: GithubApi
    kv: JsonKv
    repoName: string

converter toJson*(cr: GhcsCliRef): JsonNode =
  result = newJObject()
  result["git"] = cr.commitInfo
  if not isNil(cr.status): result["status"] = cr.status
  if not isNil(cr.metadata): result["metadata"] = cr.metadata
  if not isNil(cr.comments):
    let comments = map(cr.comments, proc(lc: LineComment): JsonNode = lc)
    result["comments"] = %(comments)

converter toJson*(cliOutput: GhcsCliOutput): JsonNode =
  result = newJObject()

  for tup in cliOutput:
    add(result, tup.name, tup.cliRef)

proc newGhcsRepo*(api: GithubApi, repo: string): GhcsRepo =
  let rawKv = newGhkv(api, repo)
  let jsonKv = JsonKv(kv: rawKv)
  result = GhcsRepo(api: api, kv: jsonKv, repoName: repo)

proc commitInfo(repo: GhcsRepo, commitName: string): CommitInfo =
  let url = "repos/" & repo.repoName & "/commits/" & commitName
  result = request(repo.api, "GET", url)

proc commitStatus(repo: GhcsRepo, commitName: string, context: string): CommitStatus =
  let url = "repos/" & repo.repoName & "/commits/" & commitName & "/status"
  let resp = request(repo.api, "GET", url)
  let statuses = toCombinedCommitStatus(resp).statuses
  result = findx(statuses, proc(cs: CommitStatus): bool = cs.context == context)

proc commitMetadata(repo: GhcsRepo, commitName: string, context: string): JsonNode =
  let key = "metadata_" & context & "_" & commitName
  let resp = get(repo.kv, key)
  result = if isNil(resp): newJObject() else: resp

proc ghcsRefOutput(repo: GhcsRepo, commitName: string, context: string): GhcsCliRef =
  let info = commitInfo(repo, commitName)
  let status = commitStatus(repo, info.sha, context)
  let metadata = commitMetadata(repo, info.sha, context)

  new(result)

  result.commitInfo = info
  result.metadata = metadata
  result.status = status

proc ghcsOutput*(repo: GhcsRepo, config: GitConfig, context: string): GhcsCliOutput =
  result = @[]

  let relevantRefs = toTable({
    "HEAD": config.sha,
    "HEAD^1": config.sha & "^1",
    "master": "master"
  })

  for name, commit in relevantRefs:
    let refOutput = ghcsRefOutput(repo, commit, context)
    add(result, (name, refOutput))
