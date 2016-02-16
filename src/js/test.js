var Ghcs = require('ghcs');

var opts = {
    url: 'http://example.com',
    method: 'GET',
    body: '',
    headers: {abc: 'def'}
};

var http = Ghcs.http(opts);
var headersJson = JSON.stringify(http.headers);
Ghcs.stdout(headersJson);
