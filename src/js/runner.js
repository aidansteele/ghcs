let Ghcs = require('ghcs');

export default class Runner {
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
