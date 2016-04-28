import github_api
import ghcs_repo
import git_config
import os
import js_executor
import patch

let config = defaultConfig()
let token = getEnv("GHCS_API_TOKEN")
let api = GithubApi(baseUri: config.baseUri, token: token)
let repo = newGhcsRepo(api, config.repoName)

if paramStr(1) == "js":
  let jsExe = newJsExecutor()
  execSourceFile(jsExe, paramStr(2))
  destroyJsExecutor(jsExe)

#echo(pretty(ghcsOutput(repo, config, "moomoo")))
# blah
