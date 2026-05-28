/* eslint-disable */
/*
Yoinked from YarnEditor source and modified to limit size and scope:

https://github.com/YarnSpinnerTool/YarnEditor/blob/master/src/js/classes/data.js

Including as a dependency would be large and subject to breakage, so we adapt it instead.

I guess this counts as a "substantial portion" (?), so:

--------------


Copyright (c) 2015 Infinite Ammo Inc. and Yarn Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/* eslint-enable */

export default function convertYarnToJS(content) {
  const objects = [];

  const lines = content.split(/\r?\n+/)
    .filter((line) => {
      return !line.match(/^\s*$/);
    });

  let obj = null;
  let readingBody = false;
  let filetags;

  // per-node, we will uniformly strip leading space
  // which can result from constructing dialogues
  // using template strings.
  let leadingSpace = '';

  let i = 0;
  while (lines[i].trim()[0] === '#') {
    if (!filetags) filetags = [];
    filetags.push(lines[i].trim().substr(1));
    i += 1;
  }
  for (; i < lines.length; i += 1) {
    if (lines[i].trim() === '===') {
      readingBody = false;
      if (filetags) obj.filetags = filetags;
      objects.push(obj);
      obj = null;
    } else if (readingBody) {
      obj.body += `${lines[i].replace(leadingSpace, '')}\n`;
    } else if (lines[i].trim() === '---') {
      readingBody = true;
      obj.body = '';
      leadingSpace = lines[i].match(/^\s*/)[0];
    } else if (lines[i].indexOf(':') > -1) {
      const separatorIndex = lines[i].indexOf(':');
      const key = lines[i].slice(0, separatorIndex);
      const value = lines[i].slice(separatorIndex + 1);
      const trimmedKey = key.trim();
      const trimmedValue = value.trim();
      if (trimmedKey !== 'body') {
        if (obj == null) obj = {};
        if (obj[trimmedKey]) {
          throw new Error(`Duplicate tag on node: ${trimmedKey}`);
        }
        obj[trimmedKey] = trimmedValue;
      }
    }
  }
  return objects;
}
