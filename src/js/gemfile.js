const Ghcs = require('ghcs');
const parser = require('gemfileParser');

export default class Gemfile {
    constructor({context = 'gemfile', directory = '.'}) {
        this.context = context;
        this.directory = directory;
    }

    run() {
        let lockfilePath = this.directory + '/Gemfile.lock';
        let lockfileData = Ghcs.readFile({ path: lockfilePath });
        let lockfile = parser.parse(lockfileData);

        return {
            status: {},
            metadata: lockfile,
            comments: {}
        };
    }
}

var Runner = require('runner');
var args = Runner.cliArguments();
var runner = new Runner(new Gemfile(args));
runner.run();
