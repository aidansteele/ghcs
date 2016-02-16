export default class Ghcs {
    static http(opts) {
        var nativeOpts = {
            url: opts.url,
            method: opts.method,
            body: opts.body,
            headers: opts.headers
        };
        return _ghcsHttp(nativeOpts);
    }

    static readFile(opts) {
        var nativeOpts = { path: opts.path };
        var ret = _ghcsReadFile(nativeOpts);
        return ret.contents;
    }

    static shell(opts) {
        var nativeOpts = { command: opts.command };
        return _ghcsShell(nativeOpts);
    }

    static meth() {
        print("sup");
        return "jhiyy";
    }

    static stdin() {
        var ret = _ghcsStdin({});
        return ret.stdin;
    }

    static stdout(output) {
        _ghcsStdout({ stdout: output })
    }
}

// TODO work out why transform-es2015-modules-commonjs isn't working
module.exports = exports["default"];
