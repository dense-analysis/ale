" Author: Alexander Olofsson <alexander.olofsson@liu.se>

call ale#linter#Define('puppet', {
\   'name': 'puppetlint',
\   'executable': 'puppet-lint',
\   'command': 'puppet-lint --no-autoloader_layout-check'
\   .   ' --log-format "-:%{line}:%{column}: %{kind}: [%{check}] %{message}"'
\   .   ' %t',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\})
