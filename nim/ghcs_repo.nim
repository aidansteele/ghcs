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
import diff
import streams
import httpcore
import http
import uri

type
  GhcsCliRef* = ref object
    metadata: JsonNode
    status: CommitStatus
    comments: seq[LineComment]

  GhcsCliOutput* = Table[CommitName, GhcsCliRef]
  GhcsCliInput* = TableRef[CommitName, TableRef[ContextName, GhcsCliRef]]

  GhcsRepo* = ref object
    api: GithubApi
    kv: JsonKv
    repoName: string

converter toJson*(cr: GhcsCliRef): JsonNode =
  result = newJObject()
  # result["git"] = cr.commitInfo
  if not isNil(cr.status): result["status"] = cr.status
  if not isNil(cr.metadata): result["metadata"] = cr.metadata
  if not isNil(cr.comments):
    let comments = map(cr.comments, proc(lc: LineComment): JsonNode = lc)
    result["comments"] = %(comments)

proc toGhcsCliRef*(json: JsonNode): GhcsCliRef =
  new(result)
  result.metadata = json["metadata"]
  result.status = json["status"]
  result.comments = mapIt(json["comments"].elems, toLineComment(it))

converter toJson*(cliOutput: GhcsCliOutput): JsonNode =
  result = newJObject()

  for name, val in cliOutput:
    add(result, string(name), val)

proc newGhcsRepo*(api: GithubApi, repo: string): GhcsRepo =
  let rawKv = newGhkv(api, repo)
  let jsonKv = JsonKv(kv: rawKv)
  result = GhcsRepo(api: api, kv: jsonKv, repoName: repo)

proc resolveCommitName(repo: GhcsRepo, commitName: CommitName): CommitName =
  let url = "repos/" & repo.repoName & "/commits/" & string(commitName)
  let info: CommitInfo = request(repo.api, "GET", url)
  result = CommitName(info.sha)

proc commitStatus(repo: GhcsRepo, commitName: CommitName, context: ContextName): CommitStatus =
  let url = "repos/" & repo.repoName & "/commits/" & string(commitName) & "/status"
  let resp = request(repo.api, "GET", url)
  let statuses = toCombinedCommitStatus(resp).statuses
  result = findx(statuses, proc(cs: CommitStatus): bool = cs.context == context)

proc setCommitStatus(repo: GhcsRepo, commitName: CommitName, context: ContextName, status: CommitStatus) =
  let url = "repos/" & repo.repoName & "/statuses/" & string(commitName)
  discard request(repo.api, "POST", url, status)

proc commitMetadataKey(commitName: CommitName, context: ContextName): string =
  return "metadata_" & string(context) & "_" & string(commitName)

proc commitMetadata(repo: GhcsRepo, commitName: CommitName, context: ContextName): JsonNode =
  let resp = get(repo.kv, commitMetadataKey(commitName, context))
  result = if isNil(resp): newJObject() else: resp

proc setCommitMetadata(repo: GhcsRepo, commitName: CommitName, context: ContextName, metadata: JsonNode) =
  set(repo.kv, commitMetadataKey(commitName, context), metadata)

proc postCommitComment(repo: GhcsRepo, commitName: CommitName, comment: LineComment) =
  discard

proc changedLinesInPR(repo: GhcsRepo, pullId: string): seq[ChangedLine] =
  let diffUrl = "repos/" & repo.repoName & "/pulls/" & pullId & ".diff"
  let headers = newHttpHeaders({"Accept": "application/vnd.github.v3.diff"})
  let uri = combine(repo.api.baseUri, parseUri(diffUrl))
  let diff = rawRequest(uri, "GET", nil, headers).body
  result = changedLinesInDiff(newStringStream(diff))

proc commentsInPR(repo: GhcsRepo, pullId: string): seq[PatchComment] =
  let url = "repos/" & repo.repoName & "/pulls/" & pullId & "/comments"
  let resp = request(repo.api, "GET", url)
  result = mapIt(resp.elems, toPatchComment(it))

proc postPullRequestComments(repo: GhcsRepo, commitName: CommitName, pullId: string, comments: seq[LineComment]) =
  let changed = changedLinesInPR(repo, pullId)
  let applicable = diffComments(comments, changed)
  let existing = commentsInPR(repo, pullId)

  for pc in applicable:
    if anyIt(existing, it == pc): continue

    let url = "repos/" & repo.repoName & "/pulls/" & pullId & "/comments"
    var commentJson: JsonNode = pc
    commentJson["commit_id"] = %string(commitName)
    discard request(repo.api, "POST", url, commentJson)

proc ghcsRefOutput(repo: GhcsRepo, commitName: CommitName, context: ContextName): GhcsCliRef =
  # let info = commitInfo(repo, commitName)
  let name = resolveCommitName(repo, commitName)
  let status = commitStatus(repo, name, context)
  let metadata = commitMetadata(repo, name, context)

  new(result)
  result.metadata = metadata
  result.status = status

proc recentPRs(repo: GhcsRepo): seq[PullRequest] =
  let url = "repos/" & repo.repoName & "/pulls?sort=updated&direction=desc"
  let node = request(repo.api, "GET", url)
  result = map(node.elems, proc(x: JsonNode): PullRequest = toPullRequest(x))      

proc prForCommit(prs: seq[PullRequest], commit: CommitName): PullRequest =
  result = findx(prs, proc(pr: PullRequest): bool = pr.headRef == commit)

proc ghcsOutput*(repo: GhcsRepo, refName: CommitName, context: ContextName): GhcsCliOutput =
  var output: GhcsCliOutput
  # TODO fix me below
  output[string(refName)] = ghcsRefOutput(repo, refName, context)

  let prs = recentPRs(repo)
  let pr = prForCommit(prs, refName)
  if pr != nil:
    output[string(pr.baseRef)] = ghcsRefOutput(repo, pr.baseRef, context)

  return output

proc ghcsInput*(repo: GhcsRepo, commitName: CommitName, context: ContextName, cliRef: GhcsCliRef) =
  setCommitMetadata(repo, commitName, context, cliRef.metadata)
  setCommitStatus(repo, commitName, context, cliRef.status)
  
  # TODO: add option for commenting on lines that aren't part of a PR
  let prs = recentPRs(repo)
  let pr = prForCommit(prs, commitName)
  if pr != nil:
    postPullRequestComments(repo, commitName, pr.pullId, cliRef.comments)  

# proc ghcsInput*(repo: GhcsRepo, input: GhcsCliInput, pullId: string) =
#   for refName, refInput in input:
#     for contextName, contextInput in refInput:
#       setCommitMetadata(repo, refName, contextName, contextInput.metadata)
#       setCommitStatus(repo, refName, contextName, contextInput.status)
      
#       # TODO: add option for commenting on lines that aren't part of a PR
#       if len(pullId) > 0:
#         postPullRequestComments(repo, refName, pullId, contextInput.comments)    
  
