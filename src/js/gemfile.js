const Ghcs = require('ghcs');
const _ = require('underscore');

const rubyCode = `
    require 'bundler'
    require 'yaml'
    require 'json'

    lockfile_path, vulns_path, *_ = ARGV

    lockfile_parser = Bundler::LockfileParser.new File.read lockfile_path
    all_deps = lockfile_parser.specs.map {|spec| [spec.name, spec.version ] }.to_h

    all_vulns = Dir["#{vulns_path}/gems/*/**.yml"].map do |path|
      YAML.load_file path
    end

    applicable_vulns = all_vulns.select do |vuln|
      patched = vuln['patched_versions'] || []
      unaffected = vuln['unaffected_versions'] || []
      safe_versions = (patched + unaffected).map do |ver|
        preds = ver.split(', ')
        Gem::Requirement.new(*preds)
      end

      gem_name = vuln['gem']
      gem_version = all_deps[gem_name]
      next if gem_version.nil?

      is_vuln = safe_versions.none? { |req| req === gem_version }
      vuln['lockfile_version'] = gem_version.to_s if is_vuln
      is_vuln
    end

    puts applicable_vulns.to_json
`;

export default class Gemfile {
    constructor({context = 'gemfile', directory = '.', description = false}) {
        this.context = context;
        this.directory = directory;
        this.description = description;
    }

    run() {
        return {
            status: this.status(),
            metadata: this.metadata(),
            comments: {}
        };
    }

    metadata() {
        let vulnerabilities = this.vulnerableGems();
        return { vulnerabilities };
    }

    status() {
        let vg = this.vulnerableGems();
        var description;
        var state;

        if (vg.length == 0) {
            state = 'success';
            description = 'No gems with known vulnerabilities';
        } else {
            state = 'failure';
            description = `${vg.length} gems with known vulnerabilities`;
        }

        return {
            state,
            description,
            target_url: '',
            context: this.context
        };
    }


    vulnerableGems() {
        if (!this.rubyOutputJson) {
            let advisoryPath = this.retrieveAdvisoryDb();

            Ghcs.shell({ command: 'touch Gemfile' }); // todo: this shouldn't be necessary

            var command = `ruby - ${this.directory}/Gemfile.lock ruby-advisory-db-master/`;
            let rawOutput = Ghcs.shell({ command: command, stdin: rubyCode });
            this.rubyOutputJson = JSON.parse(rawOutput);

            if (!this.description) {
                _.each(this.rubyOutputJson, (v) => delete v.description );
            }
        }

        return this.rubyOutputJson;
    }

    retrieveAdvisoryDb() {
        const url = 'https://github.com/rubysec/ruby-advisory-db/archive/master.tar.gz';
        let command = `curl -sL ${url} | tar xz`;
        Ghcs.shell({ command });
        return 'ruby-advisory-db-master/';
    }
}

var Runner = require('runner');
var args = Runner.cliArguments();
var runner = new Runner(new Gemfile(args));
runner.run();
