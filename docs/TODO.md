
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
- [ ] Support Bitbucket? GitLab?
- [ ] Ability to leave line-specific comments (see houndci.com)
- [x] CI to upload artifacts to S3
- [ ] CI to create signed deb/rpm packages, push to own apt repo
- [x] vendor nim
- [ ] `make nim` should vendor specified nim ver (not always HEAD)
- [x] Ensure that generated binary isn't bigger than it should be (debug mode?)
- [x] Split out docs into `docs/` dir
- [ ] Generate manpages for deb/rpm packages (use a markdown2man util)
- [ ] Check out code coverage (for ghcs itself): https://github.com/yglukhov/coverage

Possibly bundled checks:
- [ ] Whatever most common checks are around workplace
- [ ] JUnit XML
- [x] Rubocop JSON (also look at `DisplayCopNames`, `DisplayStyleGuide`)
- [x] Code Climate
- [ ] simplecov coverage (w/ persistence)
- [ ] "rubycritic" (check it out)
- [x] Bundler audit
- [ ] Outdated deps (gemfile, npm shrinkwrap, etc)
- [ ] iOS: swiftlint, oclint
- [ ] JSHint
