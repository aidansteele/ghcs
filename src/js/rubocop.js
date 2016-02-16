let Ghcs = require('ghcs');

export default class Rubocop {
    constructor() {
        this.context = 'rubocop';
        this.directory = '.';
        this.bundler = true;
    }

    run(opts) {
        let resp = { status: this.status(), metadata: this.metadata() };
        return resp;
    }

    rubocopOutput() {
        if (!this.rubocopOutputJson) {
            let bundlerPrefix = this.bundler ? 'bundle exec' : '';
            let cmd = `(cd ${this.directory} && ${bundlerPrefix} rubocop --format json)`;
            let raw = Ghcs.shell({ command: cmd }).output;
            this.rubocopOutputJson = JSON.parse(raw);
        }
        return this.rubocopOutputJson;
    }

    offenseCount() {
        return this.rubocopOutput().summary.offense_count;
    }

    metadata() {
        return { offenseCount: this.offenseCount() };
    }

    status() {
        var count = this.offenseCount();
        var description;
        var state;

        if (count == 0) {
            state = 'success';
            description = 'Rubocop found no style violations';
        } else {
            state = 'failure';
            description = `Rubocop found ${count} violations`;
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
var runner = new Runner(new Rubocop());
runner.run();
