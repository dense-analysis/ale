" Author: Alexander Olofsson <alexander.olofsson@liu.se>

call ale#linter#Define('puppet', {
\   'name': 'puppetlint',
\   'executable': 'puppet-lint',
\   'command': g:ale#util#stdin_wrapper . ' .pp puppet-lint --no-autoloader_layout-check --log-format "-:%{line}:%{column}: %{kind}: [%{check}] %{message}"',
\   'callback': 'ale#handlers#HandleGCCFormat',
\})
