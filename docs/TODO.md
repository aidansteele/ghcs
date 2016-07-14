
TO DO before 1.0 in no particular order:

- [ ] Run ES6 scripts using Babel
- [x] Bundle underscore.js
- [ ] Some kind of AWS helpers in JS?
- [x] Raise compile-time errors if babelifying fails
- [x] Link PCRE statically
- [ ] Investigate unit testing frameworks for nim
- [ ] Bundle helpful standard checks (see below)
- [ ] Validate works correctly where parent or master is a merge commit
- [ ] Check out the env vars / gitenv in various CIs (buildkite, bamboo, travis)
- [ ] Support [Bitbucket][bitbucket-api]? [GitLab][gitlab-api]?
- [x] Ability to leave line-specific comments (see houndci.com) (also see [this][no-double-up] for avoiding double ups)
- [x] CI to upload artifacts to S3
- [ ] CI to create signed deb/rpm packages, push to own apt repo
- [x] vendor nim
- [ ] `make nim` should vendor specified nim ver (not always HEAD)
- [x] Ensure that generated binary isn't bigger than it should be (debug mode?)
- [x] Split out docs into `docs/` dir
- [x] Generate manpages for deb/rpm packages (use a markdown2man util)
- [ ] Check out code coverage (for ghcs itself): https://github.com/yglukhov/coverage
- [ ] JS blackbox testing written in nim is a hack

[bitbucket-api]: https://confluence.atlassian.com/bitbucket/changesets-resource-296095208.html#changesetsResource-POSTanewcommentonachangeset
[gitlab-api]: https://github.com/gitlabhq/gitlabhq/blob/master/doc/api/commits.md#post-the-build-status-to-a-commit
[no-double-up]: https://github.com/houndci/hound/commit/abeca34b5fe1c27958389cdb6bcea244fdc5464f

Possibly bundled checks:
- [ ] Whatever most common checks are around workplace
- [ ] JUnit XML
- [x] Rubocop JSON (also look at `DisplayCopNames`, `DisplayStyleGuide`)
- [x] Code Climate
- [ ] simplecov coverage (w/ persistence)
- [ ] "rubycritic" (check it out)
- [x] Bundler audit
- [ ] Outdated deps (gemfile, npm shrinkwrap, etc)
- [x] iOS: swiftlint
- [ ] iOS: oclint
- [ ] JSHint
