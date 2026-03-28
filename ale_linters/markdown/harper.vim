" Author: Armand Halbert <armand.halbert@gmail.com>
" Description: Harper for Markdown files

call ale#Set('markdown_harper_config', {
\   'harper-ls': {
\       'diagnosticSeverity': 'hint',
\       'dialect': 'American',
\       'linters': {
\           'SpellCheck': v:true,
\           'SentenceCapitalization': v:true,
\           'RepeatedWords': v:true,
\           'LongSentences': v:true,
\           'AnA': v:true,
\           'Spaces': v:true,
\           'SpelledNumbers': v:false,
\           'WrongQuotes': v:false,
\       },
\   },
\})

call ale#linter#Define('markdown', {
\   'name': 'harper',
\   'lsp': 'stdio',
\   'executable': 'harper-ls',
\   'command': '%e --stdio',
\   'project_root': function('ale_linters#markdown#harper#GetProjectRoot'),
\   'lsp_config': {b -> ale#Var(b, 'markdown_harper_config')},
\})

function! ale_linters#markdown#harper#GetProjectRoot(buffer) abort
    return fnamemodify(bufname(a:buffer), ':p:h')
endfunction
