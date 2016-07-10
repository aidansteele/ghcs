import Ghcs from "ghcs";
import _ from "underscore";

let opts = {
    url: "http://example.com",
    method: "GET",
    body: "",
    headers: {abc: "def"}
};

let http = Ghcs.http(opts);

let xHeaders = _.chain(http.headers)
    .pairs()
    .filter(([k, v]) => k[0] == "x" || k[0] == "X")
    .object()
    .value();
let headersJson = JSON.stringify(xHeaders);
Ghcs.stdout(headersJson);
