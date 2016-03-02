export default class Ghcs {
    static http({ url, method, body = '', headers = {} }) {
        var nativeOpts = { url, method, body, headers };
        return _ghcsHttp(nativeOpts);
    }

    static readFile({ path }) {
        var nativeOpts = { path };
        var ret = _ghcsReadFile(nativeOpts);
        return ret.contents;
    }

    static writeFile({ path, data }) {
        var nativeOpts = { path, data };
        var ret = _ghcsWriteFile(nativeOpts);
    }

    static shell({ command, stdin = '' }) {
        var nativeOpts = { command, stdin };
        return _ghcsShell(nativeOpts).stdout;
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
