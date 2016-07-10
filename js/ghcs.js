export default class Ghcs {
    static http({ url, method, body = "", headers = {} }) {
        let nativeOpts = { url, method, body, headers };
        return _ghcsHttp(nativeOpts); // eslint-disable-line no-undef
    }

    static readFile({ path }) {
        let nativeOpts = { path };
        let ret = _ghcsReadFile(nativeOpts); // eslint-disable-line no-undef
        return ret.contents;
    }

    static writeFile({ path, data }) {
        let nativeOpts = { path, data };
        return _ghcsWriteFile(nativeOpts); // eslint-disable-line no-undef
    }

    static shell({ command, stdin = "" }) {
        let nativeOpts = { command, stdin };
        return _ghcsShell(nativeOpts).stdout; // eslint-disable-line no-undef
    }

    static stdin() {
        let ret = _ghcsStdin({}); // eslint-disable-line no-undef
        return ret.stdin;
    }

    static stdout(output) {
        _ghcsStdout({ stdout: output }); // eslint-disable-line no-undef
    }

    static argv() {
        return _ghcsArgv({}).argv; // eslint-disable-line no-undef
    }
}

// TODO work out why transform-es2015-modules-commonjs isn't working
module.exports = exports["default"];
