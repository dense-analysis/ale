" Author: Jeff Miccolis<jeff@miccolis.net>
" Description: oxlint for JavaScript files.

call ale#linter#Define('javascript', {
\   'name': 'oxlint',
\   'lsp': 'stdio',
\   'executable': function('ale#handlers#oxlint#GetExecutable'),
\   'command': '%e --lsp',
\   'project_root': function('ale#handlers#oxlint#GetProjectRoot'),
\   'initialization_options': function('ale#handlers#oxlint#GetInitializationOptions'),
\})
