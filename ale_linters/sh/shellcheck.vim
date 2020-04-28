" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for using the shellcheck linter with
"   shell scripts.

call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable':  function('ale#handlers#shellcheck#GetExecutable'),
\   'command': function('ale#handlers#shellcheck#GetCommand'),
\   'callback': 'ale#handlers#shellcheck#Handle',
\})
