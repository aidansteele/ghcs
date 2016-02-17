## `rubocop`

> RuboCop is a Ruby static code analyzer. Out of the box it will enforce many 
> of the guidelines outlined in the community Ruby Style Guide.

-- [Rubocop README][rubocop]

The built-in `rubocop` check by default will execute 
`bundle exec rubocop --format json` in the working directory. There are a few 
configuration options:

* `--directory path/to/ruby/src` if your Ruby code doesn't reside in `$PWD`.
* `--path path/to/rubocop.json` if you have already saved the Rubocop output 
  in a previous step.
* `--bundler false` if for some reason you don't want to run within a Bundler env.

[rubocop]: https://github.com/bbatsov/rubocop

## `codeclimate`

> Get automated code review for test coverage, complexity, duplication, security, 
> style, and more, and merge with confidence.

-- [Code Climate][codeclimate]

The built-in `codeclimate` check by default will run the `codeclimate` CLI tool
[provided][codeclimate-cli] by Code Climate. It requires Docker to be installed
on the machine running `ghcs`.

[codeclimate]: https://codeclimate.com/
[codeclimate-cli]: https://github.com/codeclimate/codeclimate
