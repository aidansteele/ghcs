/*
 Taken from https://github.com/treycordova/gemfile/blob/master/gemfile.js:

 The MIT License (MIT)

 Copyright © 2016 Trey Cordova

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

'use strict';

const WHITESPACE = /^(\s*)/;
const GEMFILE_KEY_VALUE = /^\s*([^:(]*)\s*\:*\s*(.*)/;

export function parse(string) {
    let line;
    let level;
    let index = 0;
    let previousWhitespace = -1;
    let gemfile = level = {};
    let lines = string.split('\n');
    let stack = [];

    while((line = lines[index++]) !== undefined) {

        // Handle depth stack changes

        let whitespace = WHITESPACE.exec(line)[1].length;

        if (whitespace <= previousWhitespace) {
            let stackIndex = stack.length - 1;

            while(stack[stackIndex] && (whitespace <= stack[stackIndex].depth)) {
                stack.pop();
                stackIndex--;
            }
        }

        // Make note of line's whitespace depth

        previousWhitespace = whitespace;

        // Handle new key/value leaf

        let parts = GEMFILE_KEY_VALUE.exec(line);
        let key = parts[1].trim();
        let value = parts[2] || '';

        if (key) {

            // Handle path traversal

            let level = gemfile;

            for (let stackIndex = 0; stackIndex < stack.length; stackIndex++) {
                if (level[stack[stackIndex].key]) {
                    level = level[stack[stackIndex].key];
                }
            }

            // Handle data type inference

            let data = {};

            if (value.indexOf('/') > -1)  {
                data.path = value;
            } else if (value.indexOf('(') > -1) {
                if (value[value.length - 1] === '!') {
                    value = value.substring(0, value.length - 1);
                    data.outsourced = true;
                }

                if (value[1] !== ')') {
                    data.version = value.substring(1, value.length - 1);
                }
            } else if (/\b[0-9a-f]{7,40}\b/.test(value)) {
                data.sha = value;
            }

            // Set key at current level

            level[key] = data;

            // Push key on stack

            stack.push({key, depth: whitespace});
        }
    }

    let keys = Object.keys(gemfile);

    let hasGemKey = keys.indexOf('GEM') > -1;
    let hasDependenciesKey = keys.indexOf('DEPENDENCIES') > -1;
    let hasPlatformsKey = keys.indexOf('PLATFORMS') > -1;

    if (!hasGemKey || !hasDependenciesKey || !hasPlatformsKey) {
        throw 'Probably not a Gemfile.lock';
    }


    if (gemfile['BUNDLED WITH']) {
        gemfile['BUNDLED WITH'] = Object.keys(gemfile['BUNDLED WITH'])[0];
    }

    return gemfile;
}
