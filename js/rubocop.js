import Ghcs from "ghcs";
import _ from "underscore";

export default class Rubocop {
    constructor({context = "rubocop", directory = ".", bundler = true, path}) {
        this.context = context;
        this.directory = directory;
        this.bundler = bundler;
        this.path = path;
    }

    run() {
        return {
            status: this.status(),
            metadata: this.metadata(),
            comments: this.comments()
        };
    }

    rubocopOutput() {
        if (!this.rubocopOutputJson) {
            if (this.path) {
                let raw = Ghcs.readFile({ path: this.path });
                this.rubocopOutputJson = JSON.parse(raw);
            } else {
                let bundlerPrefix = this.bundler ? "bundle exec " : "";
                let cmd = `(cd ${this.directory} && ${bundlerPrefix}rubocop --format json)`;
                let raw = Ghcs.shell({ command: cmd });
                this.rubocopOutputJson = JSON.parse(raw);
            }
        }
        return this.rubocopOutputJson;
    }

    offenseCount() {
        return this.rubocopOutput().summary.offense_count;
    }

    metadata() {
        return { offenseCount: this.offenseCount() };
    }

    comments() {
        let files = this.rubocopOutput().files;
        return _.flatten(_.map(files, (file) => {
            return _.map(file.offenses, (offense) => {
                return {
                    path: file.path,
                    line: offense.location.line,
                    body: offense.message
                };
            });
        }));
    }

    status() {
        var count = this.offenseCount();
        var description;
        var state;

        if (count == 0) {
            state = "success";
            description = "Rubocop found no style violations";
        } else {
            state = "failure";
            description = `Rubocop found ${count} violations`;
        }
        
        return {
            state,
            description,
            target_url: "",
            context: this.context
        };
    }
}

import Runner from "runner";
let args = Runner.cliArguments();
let runner = new Runner(new Rubocop(args));
runner.run();
