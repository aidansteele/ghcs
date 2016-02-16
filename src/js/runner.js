let Ghcs = require('ghcs');

export default class Runner {
    static cliArguments() {
        var args = {};
        var argv = Ghcs.argv();

        for (var i = 2; i < argv.length; i += 2) {
            var key = argv[i].substr(2);
            var val = argv[i + 1];
            args[key] = val;
        }

        return args;
    }

    constructor(check) {
        this.check = check;
    }

    run() {
        let checkOutput = this.check.run();
        let context = this.check.context;

        var output = { HEAD: {} };
        output.HEAD[context] = checkOutput;

        let json = JSON.stringify(output);
        Ghcs.stdout(json);
    }
}

module.exports = exports["default"];
