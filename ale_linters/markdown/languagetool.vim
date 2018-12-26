" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: languagetool for markdown files


call ale#linter#Define('markdown', {
    \   'name': 'languagetool',
    \   'executable': 'languagetool',
    \   'command': 'languagetool %s ',
    \   'output_stream': 'stdout',
    \   'callback': 'ale#handlers#languagetool#HandleOutput',
    \   'lint_file': 1,
\})
