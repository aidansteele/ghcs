let Ghcs = require('ghcs');

export default class CodeClimate {
    constructor({context = 'codeclimate', directory = '.', path}) {
        this.context = context;
        this.directory = directory;
        this.path = path;
    }

    run(opts) {
        return { status: this.status(), metadata: this.metadata() };
    }

    codeclimateOutput() {
        if (!this.codeclimateJsonOutputJson) {
            if (this.path) {
                let raw = Ghcs.readFile({ path: this.path });
                this.codeclimateJsonOutputJson = JSON.parse(raw);
            } else {
                let cmd = `(cd ${this.directory} && codeclimate analyze -f json)`;
                let raw = Ghcs.shell({ command: cmd }).output;
                this.codeclimateJsonOutputJson = JSON.parse(raw);
            }
        }
        return this.codeclimateJsonOutputJson;
    }

    issueCount() {
        return this.codeclimateOutput().length;
    }

    metadata() {
        return { issueCount: this.issueCount() };
    }

    status() {
        var count = this.issueCount();
        var description;
        var state;

        if (count == 0) {
            state = 'success';
            description = 'Code Climate found no issues';
        } else {
            state = 'failure';
            description = `Code Climate found ${count} issues`;
        }

        return {
            state,
            description,
            target_url: '',
            context: this.context
        };
    }
}

var Runner = require('runner');
var args = Runner.cliArguments();
var runner = new Runner(new CodeClimate(args));
runner.run();
