var Ghcs = require('ghcs');
var _ = require('underscore');

var opts = {
    url: 'http://example.com',
    method: 'GET',
    body: '',
    headers: {abc: 'def'}
};

var http = Ghcs.http(opts);

var xHeaders = _.chain(http.headers)
    .pairs()
    .filter(([k, v]) => k[0] == 'x' || k[0] == 'X')
    .object()
    .value();
var headersJson = JSON.stringify(xHeaders);
Ghcs.stdout(headersJson);
