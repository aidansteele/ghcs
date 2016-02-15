Duktape.modSearch = function (id, require, exports, module) {
    var bundled = _readJavascriptSource(id);

    if (bundled.length > 0) {
        return bundled;
    } else {
        throw new Error('cannot find module: ' + id);
    }
};
