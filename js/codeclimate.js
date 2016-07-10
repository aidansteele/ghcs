import Ghcs from "ghcs";

export default class CodeClimate {
    constructor({context = "codeclimate", directory = ".", path}) {
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
                let normalizedPath = Ghcs.shell({ command: `(cd ${this.directory} && pwd)` }).trim();
                let dockerCmd = `
                    docker run \
                      --interactive --rm \
                      --env CODE_PATH="${normalizedPath}" \
                      --volume "${normalizedPath}":/code \
                      --volume /var/run/docker.sock:/var/run/docker.sock \
                      --volume /tmp/cc:/tmp/cc \
                      codeclimate/codeclimate \
                `;
                let cmd = `(cd ${this.directory} && ${dockerCmd} analyze -f json)`;
                let raw = Ghcs.shell({ command: cmd });
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
        let count = this.issueCount();
        var description;
        var state;

        if (count == 0) {
            state = "success";
            description = "Code Climate found no issues";
        } else {
            state = "failure";
            description = `Code Climate found ${count} issues`;
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
let runner = new Runner(new CodeClimate(args));
runner.run();
