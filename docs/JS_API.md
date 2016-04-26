# Javascript API

To minimise external dependencies, the JavaScript engine is _not_ Node.js. The 
JavaScript VM is provided by the [Duktape][duktape] library. Therefore some of 
the niceties that you've come to love and expect may be missing.

This document should serve as a complete reference of the built-in functionality 
available to you. If there is any missing crucial functionality, please open 
an issue.

## HTTP calls

```js
var response = Ghcs.http({
  url: 'http://example.com/', 
  method: 'POST',
  body: JSON.stringify({hello: world}),
  headers: {
    'X-Custom-Header': 'Hello World'
  }
});

response.body == "hello world"; // body is a string
response.statusCode == 200; // status code is a number
response.headers['Date'] != undefined; // response headers object
```

## Filesystem IO

```js
var data = Ghcs.readFile("/path/to/file"); // data will be a string
```

## Process IO

```js
var input = Ghcs.stdin();
// input will be a string

var out = JSON.stringify({hello: "world"});
Ghcs.stdout(out);
// returns nothing, but prints param to stdout

var result = Ghcs.shell({command: "ls -l | wc -l"});
// result is "      18"
```
