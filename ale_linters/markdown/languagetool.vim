" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: languagetool for markdown files

" TODO: 
" - Add language detection settings based on user env (for mothertongue)
" - Add fixer
" - Add config options for rules

call ale#linter#Define('markdown', {
    \   'name': 'languagetool',
    \   'executable': 'languagetool',
    \   'command': 'languagetool --autoDetect %s ',
    \   'output_stream': 'stdout',
    \   'callback': 'ale#handlers#languagetool#HandleOutput',
    \   'lint_file': 1,
\})
