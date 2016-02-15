export default class Ghcs {
    static http(opts) {

    }

    static readFile(opts) {
        return _readJavascriptSource(opts.path);
    }

    static shell(opts) {

    }

    static meth() {
        print("sup");
        return "jhiyy";
    }

    static stdin() {

    }

    static stdout(output) {

    }
}

// TODO work out why transform-es2015-modules-commonjs isn't working
module.exports = exports["default"];
