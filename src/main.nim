import github_api
import ghcs_repo
import git_config
import os
import js_executor

let config = defaultConfig()
let token = getEnv("GHCS_API_TOKEN")
let api = GithubApi(baseUrl: config.baseUrl, token: token)
let repo = newGhcsRepo(api, config.repoName)

let jsExe = newJsExecutor()
execSourceFile(jsExe, paramStr(1))
destroyJsExecutor(jsExe)

#echo(pretty(ghcsOutput(repo, config, "moomoo")))
# blah
