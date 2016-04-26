let Ghcs = require('ghcs');
let _ = require('underscore');

export default class Swiftlint {
    constructor({context = 'swiftlint', directory = '.', path}) {
        this.context = context;
        this.directory = directory;
        this.path = path;
    }

    run() {
        return {
          status: this.status(),
          metadata: this.metadata(),
          comments: this.comments()
        };
    }
    
    swiftlintOutput() {
        if (!this.swiftlintOutputJson) {
            if (this.path) {
                let raw = Ghcs.readFile({ path: this.path });
                this.swiftlintOutputJson = JSON.parse(raw);
            } else {
                let command = `(cd ${this.directory} && swiftlint lint --reporter json --quiet)`;
                let raw = Ghcs.shell({ command });
                this.swiftlintOutputJson = JSON.parse(raw);
            }
        }
        return this.swiftlintOutputJson;
    }

    warningCount() {
        return this.swiftlintOutput().length;
    }

    metadata() {
        return { warningCount: this.warningCount() };
    }

    comments() {
        return _.map(this.swiftlintOutput(), (warning) => {
            let path = warning.file.slice(this.directory); // remove absolute path prefix
            let line = warning.line;
            let body = warning.reason;
            return { path, line, body };
        });
    }

    status() {
        var count = this.warningCount();
        var description;
        var state;

        if (count == 0) {
            state = 'success';
            description = 'Swiftlint found no style violations';
        } else {
            state = 'failure';
            description = `Swiftlint found ${count} violations`;
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
var runner = new Runner(new Swiftlint(args));
runner.run();
