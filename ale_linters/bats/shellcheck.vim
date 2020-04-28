" Author: Ian2020 <https://github.com/Ian2020>
" Description: This file adds support for using the shellcheck linter with
"   bats scripts. Heavily inspired by/copied from work by w0rp on shellcheck
"   for sh files.

call ale#linter#Define('bats', {
\   'name': 'shellcheck',
\   'executable':  function('ale#handlers#shellcheck#GetExecutable'),
\   'command': function('ale#handlers#shellcheck#GetCommand'),
\   'callback': 'ale#handlers#shellcheck#Handle',
\})
