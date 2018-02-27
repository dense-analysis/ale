" Author: tokida https://rouger.info
" Description: textlint, a proofreading tool (https://textlint.github.io/)

call ale#linter#Define('markdown', {
\   'name': 'textlint',
\   'executable': 'textlint',
\   'command': 'if [ -f .textlintrc ]; then textlint -f json %t ; else echo "[{\"filePath\":\"%t\",\"messages\":[]}]"; fi',
\   'callback': 'ale#handlers#textlint#HandleTextlintOutput',
\})
