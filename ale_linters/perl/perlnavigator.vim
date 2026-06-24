" Author: rymdbar <https://rymdbar.x20.se/>
" Description: Perl Navigator Language Server
" See: https://github.com/bscan/PerlNavigator

call ale#Set('perl_perlnavigator_config', {})
call ale#Set('perl_perlnavigator_executable', 'perlnavigator')

call ale#linter#Define('perl', {
\   'name': 'perlnavigator',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'perl_perlnavigator_executable')},
\   'command': '%e --stdio',
\   'lsp_config': {b -> ale#Var(b, 'perl_perlnavigator_config')},
\   'project_root': function('ale#handlers#perl#GetProjectRoot'),
\ })
