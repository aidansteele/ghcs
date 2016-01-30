
TO DO before 1.0 in no particular order:

- [ ] Run ES6 scripts using Babel
- [ ] Investigate unit testing frameworks for nim
- [ ] Bundle helpful standard checks (see below)
- [ ] Validate works correctly where parent or master is a merge commit
- [ ] Check out the env vars / gitenv in various CIs (buildkite, bamboo, travis)
- [ ] Support Bitbucket? GitLab?
- [ ] Ability to leave line-specific comments (see houndci.com)
- [ ] CI to upload artifacts to S3, create signed deb/rpm packages, push to own apt repo
- [ ] `ci/setup_nim.sh` should check out nim/nimble refs specified in top-level dir (not HEAD)
- [ ] Ensure that generated binary isn't bigger than it should be (debug mode?)
- [ ] Split out docs into `docs/` dir
- [ ] Generate manpages for deb/rpm packages (use a markdown2man util)

Possibly bundled checks:
- [ ] Whatever most common checks are around workplace
- [ ] JUnit XML
- [ ] Rubocop JSON (also look at `DisplayCopNames`, `DisplayStyleGuide`)
- [ ] Code Climate
- [ ] simplecov coverage (w/ persistence)
- [ ] "rubycritic" (check it out)
- [ ] Bundler audit
- [ ] Outdated deps (gemfile, npm shrinkwrap, etc)
- [ ] iOS: swiftlint, oclint
- [ ] JSHint
