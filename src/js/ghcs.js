export default class Ghcs {
    static http({ url, method, body, headers }) {
        var nativeOpts = { url, method, body, headers };
        return _ghcsHttp(nativeOpts);
    }

    static readFile({ path }) {
        var nativeOpts = { path };
        var ret = _ghcsReadFile(nativeOpts);
        return ret.contents;
    }

    static shell({ command }) {
        var nativeOpts = { command };
        return _ghcsShell(nativeOpts).output;
    }

    static stdin() {
        var ret = _ghcsStdin({});
        return ret.stdin;
    }

    static stdout(output) {
        _ghcsStdout({ stdout: output })
    }

    static argv() {
        return _ghcsArgv({}).argv;
    }
}

// TODO work out why transform-es2015-modules-commonjs isn't working
module.exports = exports["default"];
