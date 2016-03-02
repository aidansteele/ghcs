const Ghcs = require('ghcs');
const parser = require('gemfileParser');
const _ = require('underscore');

export default class Gemfile {
    constructor({context = 'gemfile', directory = '.'}) {
        this.context = context;
        this.directory = directory;
    }

    run() {
        this.vulnerabilities();
        return {
            status: {},
            metadata: { dependencies: this.dependencies() },
            comments: {}
        };
    }

    lockfile() {
        let lockfilePath = this.directory + '/Gemfile.lock';
        let lockfileData = Ghcs.readFile({ path: lockfilePath });
        return parser.parse(lockfileData);
    }

    dependencies() {
        let specs = this.lockfile().GEM.specs;
        let pairs = _.map(specs, (data, dep) => [dep, data.version]);
        return _.object(pairs);
    }

    vulnerabilities() {
        const url = 'https://codeload.github.com/rubysec/ruby-advisory-db/zip/master';
        const path = 'ruby-advisory-db.zip';
        let data = Ghcs.http({ url, method: 'GET' }).body;
        Ghcs.writeFile({ path, data });
    }
}

var Runner = require('runner');
var args = Runner.cliArguments();
var runner = new Runner(new Gemfile(args));
runner.run();
