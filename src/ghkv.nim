import json
import base64
import strutils

import github_api

type
  Ghkv* = ref object of RootObj
    api: GithubApi
    namespace: string

proc newGhkv*(api: GithubApi, repo: string, namespace: string = "ghkv"): Ghkv =
  let newApi = GithubApi(baseUrl: api.baseUrl & "repos/" & repo & "/", token: api.token)
  result = Ghkv(api: newApi, namespace: namespace)

proc get*(ghkv: Ghkv, key: string): string =
  let url = "git/refs/" & ghkv.namespace & "/" & key
  let resp = request(ghkv.api, "GET", url)
  let obj = resp["object"]
  if isNil(obj): return nil

  # TODO: we really need to use a URL library
  let blobUrl = replace(obj["url"].str, ghkv.api.baseUrl, "")
  let blob = request(ghkv.api, "GET", blobUrl)
  result = decode(blob["content"].str)

proc delete*(ghkv: Ghkv, key: string): void =
  let url = "git/refs/" & ghkv.namespace & "/" & key
  discard request(ghkv.api, "DELETE", url)

proc createRef(ghkv: Ghkv, key: string, sha: string): void =
  let gitRef = "refs/" & ghkv.namespace & "/" & key
  let payload = %*{ "ref": gitRef, "sha": sha }
  discard request(ghkv.api, "POST", "git/refs", payload)

proc updateRef(ghkv: Ghkv, key: string, sha: string): void =
  let url = "git/refs/" & ghkv.namespace & "/" & key
  let payload = %*{ "force": true, "sha": sha }
  discard request(ghkv.api, "PATCH", url, payload)

proc set*(ghkv: Ghkv, key: string, value: string): void =
  let encoded = encode(value, lineLen=1024)
  let payload = %*{ "encoding": "base64", "content": encoded }
  let blob = request(ghkv.api, "POST", "git/blobs", payload)
  let sha = blob["sha"].str

  if isNil(get(ghkv, key)):
    createRef(ghkv, key, sha)
  else:
    updateRef(ghkv, key, sha)